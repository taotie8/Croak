import Foundation
import StoreKit

@objcMembers
@objc(Croak_StoreKitPurchaseProduct)
public final class Croak_StoreKitPurchaseProduct: NSObject {
    public let croak_productIdentifier: String
    public let croak_displayPrice: String

    init(productIdentifier: String, displayPrice: String) {
        self.croak_productIdentifier = productIdentifier
        self.croak_displayPrice = displayPrice
        super.init()
    }
}

@objcMembers
@objc(Croak_StoreKitPurchaseResult)
public final class Croak_StoreKitPurchaseResult: NSObject {
    public let croak_productIdentifier: String
    public let croak_displayPrice: String
    public let croak_transactionIdentifier: String

    init(productIdentifier: String,
         displayPrice: String,
         transactionIdentifier: String) {
        self.croak_productIdentifier = productIdentifier
        self.croak_displayPrice = displayPrice
        self.croak_transactionIdentifier = transactionIdentifier
        super.init()
    }
}

@objcMembers
@objc(Croak_StoreKitPurchaseManager)
public final class Croak_StoreKitPurchaseManager: NSObject {
    private static let sharedManager = Croak_StoreKitPurchaseManager()
    private static let errorDomain = "CroakStoreKitPurchaseErrorDomain"
    private var cachedProducts: [String: Product] = [:]
    private var pendingTransactions: [String: Transaction] = [:]

    @objc(croak_sharedManager)
    public class func croak_sharedManager() -> Croak_StoreKitPurchaseManager {
        return sharedManager
    }

    public func croak_fetchProductIdentifiers(_ productIdentifiers: [String],
                                              completion: @escaping ([Croak_StoreKitPurchaseProduct]?, NSError?) -> Void) {
        Task { @MainActor in
            do {
                let identifiers = productIdentifiers.filter { !$0.isEmpty }
                let products = try await Product.products(for: identifiers)
                cachedProducts = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
                let productsByIdentifier = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
                let purchaseProducts = identifiers.compactMap { identifier -> Croak_StoreKitPurchaseProduct? in
                    guard let product = productsByIdentifier[identifier] else {
                        return nil
                    }
                    return Croak_StoreKitPurchaseProduct(productIdentifier: product.id,
                                                         displayPrice: product.displayPrice)
                }
                completion(purchaseProducts, nil)
            } catch {
                completion(nil, croak_error(code: 1001,
                                            message: error.localizedDescription))
            }
        }
    }

    public func croak_purchaseProductIdentifier(_ productIdentifier: String,
                                                completion: @escaping (Croak_StoreKitPurchaseResult?, NSError?) -> Void) {
        Task { @MainActor in
            do {
                let product = try await croak_product(forProductIdentifier: productIdentifier)
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    let transaction = try croak_verifiedTransaction(from: verification)
                    let transactionIdentifier = String(transaction.id)
                    pendingTransactions[transactionIdentifier] = transaction
                    let purchaseResult = Croak_StoreKitPurchaseResult(productIdentifier: product.id,
                                                                      displayPrice: product.displayPrice,
                                                                      transactionIdentifier: transactionIdentifier)
                    completion(purchaseResult, nil)
                case .userCancelled:
                    completion(nil, nil)
                case .pending:
                    completion(nil, croak_error(code: 1002,
                                                message: "Purchase is pending approval."))
                @unknown default:
                    completion(nil, croak_error(code: 1003,
                                                message: "Purchase could not be completed."))
                }
            } catch {
                completion(nil, croak_error(code: 1004,
                                            message: error.localizedDescription))
            }
        }
    }

    public func croak_finishTransactionIdentifier(_ transactionIdentifier: String,
                                                  completion: @escaping (NSError?) -> Void) {
        Task { @MainActor in
            guard let transaction = pendingTransactions.removeValue(forKey: transactionIdentifier) else {
                completion(nil)
                return
            }

            await transaction.finish()
            completion(nil)
        }
    }

    private func croak_product(forProductIdentifier productIdentifier: String) async throws -> Product {
        if let product = cachedProducts[productIdentifier] {
            return product
        }

        let products = try await Product.products(for: [productIdentifier])
        guard let product = products.first else {
            throw croak_error(code: 1005,
                              message: "Product is not available.")
        }
        cachedProducts[productIdentifier] = product
        return product
    }

    private func croak_verifiedTransaction(from verification: VerificationResult<Transaction>) throws -> Transaction {
        switch verification {
        case .verified(let transaction):
            return transaction
        case .unverified(_, let error):
            throw croak_error(code: 1006,
                              message: error.localizedDescription)
        }
    }

    private func croak_error(code: Int, message: String) -> NSError {
        return NSError(domain: Self.errorDomain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message
        ])
    }
}
