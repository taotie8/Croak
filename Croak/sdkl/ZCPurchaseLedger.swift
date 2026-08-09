import StoreKit
import Foundation

class ZCPurchaseLedger: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate {
    static let shared = ZCPurchaseLedger()
    var zcOrderCode: String = ""
    private var zcShelfRequest: SKProductsRequest?
    private var zcReceiptRefreshRequest: SKReceiptRefreshRequest?
    private var zcPendingReceiptTransaction: SKPaymentTransaction?
    private var zcPendingReceiptOrderCode: String = ""
    private var zcRetriedReceiptKeys = Set<String>()
    private var zcWatchingQueue = false
    private var zcRunningSKU: String = ""
    private let zcPendingOrderMapKey = ZCRuntimeProfile.pendingOrderStoreKey

    func zcBindStoreQueue() {
        guard zcWatchingQueue == false else { return }
        zcWatchingQueue = true

        SKPaymentQueue.default().add(self)
    }

    func zcOpenOrder(zcProductId: String, zcOrderCode: String) {
        guard SKPaymentQueue.canMakePayments() else {
            ZCLoadingCurtain.zcFadeSpin()
            return
        }

        ZCLoadingCurtain.zcSpin()
        self.zcOrderCode = zcOrderCode
        zcRunningSKU = zcProductId
        zcRememberOrder(zcProductId: zcProductId, zcOrderCode: zcOrderCode)
        zcShelfRequest = SKProductsRequest(productIdentifiers: [zcProductId])
        zcShelfRequest?.delegate = self
        zcShelfRequest?.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if zcTraceEnabled == true {
            print("Products: \(response.products.map { $0.localizedTitle })")
        }

        guard let zcProduct = response.products.first else {
            ZCLoadingCurtain.zcFadeSpin()
            return
        }

        let zcPayment = SKMutablePayment(product: zcProduct)
        zcPayment.applicationUsername = zcOrderCode
        SKPaymentQueue.default().add(zcPayment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                let zcOrderCode = zcOrderCode(for: transaction)

                if zcOrderCode.isEmpty {
                    zcFinishUnrecoverableTransaction(transaction)
                    continue
                }

                zcCheckReceipt(zcTransaction: transaction, zcOrderCode: zcOrderCode)
            case .failed, .restored:
                zcForgetOrder(zcProductId: transaction.payment.productIdentifier)
                ZCLoadingCurtain.zcFadeSpin()
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }

    private func zcOrderCode(for transaction: SKPaymentTransaction) -> String {
        if let orderCode = transaction.payment.applicationUsername,
           !orderCode.isEmpty {
            return orderCode
        }

        if transaction.payment.productIdentifier == zcRunningSKU,
           !zcOrderCode.isEmpty {
            return zcOrderCode
        }

        return zcStoredOrderCode(zcProductId: transaction.payment.productIdentifier) ?? ""
    }

    private func zcFinishUnrecoverableTransaction(_ transaction: SKPaymentTransaction) {
        zcForgetOrder(zcProductId: transaction.payment.productIdentifier)
        ZCLoadingCurtain.zcFadeSpin()

        if zcTraceEnabled {
            print("Finishing StoreKit transaction without orderCode: \(transaction.payment.productIdentifier)")
        }

        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func zcRememberOrder(zcProductId: String, zcOrderCode: String) {
        guard !zcProductId.isEmpty, !zcOrderCode.isEmpty else { return }

        var pendingOrders = zcPendingOrders()
        pendingOrders[zcProductId] = zcOrderCode
        UserDefaults.standard.set(pendingOrders, forKey: zcPendingOrderMapKey)
    }

    private func zcStoredOrderCode(zcProductId: String) -> String? {
        guard !zcProductId.isEmpty else { return nil }
        return zcPendingOrders()[zcProductId]
    }

    private func zcForgetOrder(zcProductId: String, zcOrderCode: String? = nil) {
        guard !zcProductId.isEmpty else { return }

        var pendingOrders = zcPendingOrders()
        if let zcOrderCode,
           pendingOrders[zcProductId] != zcOrderCode {
            return
        }

        pendingOrders.removeValue(forKey: zcProductId)
        UserDefaults.standard.set(pendingOrders, forKey: zcPendingOrderMapKey)
    }

    private func zcPendingOrders() -> [String: String] {
        UserDefaults.standard.dictionary(forKey: zcPendingOrderMapKey) as? [String: String] ?? [:]
    }

    func zcCheckReceipt(zcTransaction: SKPaymentTransaction, zcOrderCode: String) {
        if let receiptString = zcReadReceiptBase64() {
            zcSendReceiptEnvelope(zcTransaction: zcTransaction, zcReceiptBase64: receiptString, zcOrderCode: zcOrderCode)
            return
        }

        zcRefreshReceiptOnce(zcTransaction: zcTransaction, zcOrderCode: zcOrderCode)
    }

    private func zcReadReceiptBase64() -> String? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return nil
        }

        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            let receiptString = receiptData.base64EncodedString(options: [])
            return receiptString.isEmpty ? nil : receiptString
        } catch {
            if zcTraceEnabled {
                print("Receipt read failed: \(error.localizedDescription)")
            }
            return nil
        }
    }

    private func zcRefreshReceiptOnce(zcTransaction: SKPaymentTransaction, zcOrderCode: String) {
        let retryKey = zcReceiptRetryKey(zcTransaction: zcTransaction, zcOrderCode: zcOrderCode)
        guard zcRetriedReceiptKeys.contains(retryKey) == false else {
            ZCLoadingCurtain.zcFadeSpin()
            return
        }

        zcRetriedReceiptKeys.insert(retryKey)
        zcPendingReceiptTransaction = zcTransaction
        zcPendingReceiptOrderCode = zcOrderCode

        zcReceiptRefreshRequest?.cancel()
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        zcReceiptRefreshRequest = request
        request.start()
    }

    private func zcReceiptRetryKey(zcTransaction: SKPaymentTransaction, zcOrderCode: String) -> String {
        if let transactionIdentifier = zcTransaction.transactionIdentifier,
           transactionIdentifier.isEmpty == false {
            return transactionIdentifier
        }

        return "\(zcTransaction.payment.productIdentifier)#\(zcOrderCode)"
    }

    func requestDidFinish(_ request: SKRequest) {
        guard request === zcReceiptRefreshRequest else { return }

        zcReceiptRefreshRequest = nil
        guard let transaction = zcPendingReceiptTransaction,
              zcPendingReceiptOrderCode.isEmpty == false,
              let receiptString = zcReadReceiptBase64() else {
            zcPendingReceiptTransaction = nil
            zcPendingReceiptOrderCode = ""
            ZCLoadingCurtain.zcFadeSpin()
            return
        }

        let orderCode = zcPendingReceiptOrderCode
        zcPendingReceiptTransaction = nil
        zcPendingReceiptOrderCode = ""

        zcSendReceiptEnvelope(zcTransaction: transaction, zcReceiptBase64: receiptString, zcOrderCode: orderCode)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard request === zcReceiptRefreshRequest else { return }

        zcReceiptRefreshRequest = nil
        zcPendingReceiptTransaction = nil
        zcPendingReceiptOrderCode = ""
        ZCLoadingCurtain.zcFadeSpin()

        if zcTraceEnabled {
            print("Receipt refresh failed: \(error.localizedDescription)")
        }
    }

    func zcSendReceiptEnvelope(zcTransaction: SKPaymentTransaction, zcReceiptBase64: String, zcOrderCode: String) {
        let zcParam: [String: Any] = [
            "dfrt": zcTransaction.transactionIdentifier ?? "",
            "cfgrp": zcReceiptBase64,
            "qwfgc": zcPackOrderJSON(zcDictionary: ["orderCode": zcOrderCode])
        ]

        ZCSealedPostClient.zcSendSealedPost(path: "opi/v1/qavto/reskup", parameters: zcParam, allowsPlainResponse: true) { result, _ in
            switch result {
            case .success:
                self.zcForgetOrder(zcProductId: zcTransaction.payment.productIdentifier, zcOrderCode: zcOrderCode)

                DispatchQueue.main.async {
                    ZCLoadingCurtain.zcFadeSpin()
                    SKPaymentQueue.default().finishTransaction(zcTransaction)
                }
            case .failure:
                DispatchQueue.main.async {
                    ZCLoadingCurtain.zcFadeSpin()
                }
            }
        }
    }

    func zcPackOrderJSON(zcDictionary: [String: String]) -> String {
        zcEncodePlainJSON(zcDictionary) ?? ""
    }
}
