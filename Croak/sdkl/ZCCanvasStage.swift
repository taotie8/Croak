import Foundation
import UIKit
import WebKit

class ZCCanvasStage: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    private let launchImageView = UIImageView()
    private let zcCanvasSpinner = UIActivityIndicatorView(style: .large)
    private let zcBlindView = UIView()
    private let zcShieldView = ZCSecureSurfaceView()
    private let zcAllowedSchemes: Set<String> = ["http", "https", "file", "chrome", "data", "javascript", "about"]
    var zcEntryURLText: String = ""
    var zcDidFallBackToSignin: Bool = false
    var zcCanvasWebView: WKWebView!
    var zcCanvasStartTick = Int(Date().timeIntervalSince1970 * 1000)
    var zcCanvasDuration: Int = 0

    private func zcMountShieldedStage() {
        view.backgroundColor = .black

        zcBlindView.backgroundColor = .black
        view.addSubview(zcBlindView)
        zcClampEdges(zcBlindView, to: view)

        let zcBackdropImageView = UIImageView(image: UIImage(named: zcSigninAssetName))
        zcBackdropImageView.contentMode = .scaleAspectFill
        zcBackdropImageView.clipsToBounds = true

        zcBlindView.addSubview(zcBackdropImageView)
        zcBackdropImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            zcBackdropImageView.centerXAnchor.constraint(equalTo: zcBlindView.centerXAnchor),
            zcBackdropImageView.centerYAnchor.constraint(equalTo: zcBlindView.centerYAnchor),
            zcBackdropImageView.leadingAnchor.constraint(greaterThanOrEqualTo: zcBlindView.leadingAnchor, constant: 24),
            zcBackdropImageView.trailingAnchor.constraint(lessThanOrEqualTo: zcBlindView.trailingAnchor, constant: -24),
            zcBackdropImageView.widthAnchor.constraint(lessThanOrEqualTo: zcBlindView.widthAnchor, multiplier: 0.75),
            zcBackdropImageView.heightAnchor.constraint(lessThanOrEqualTo: zcBlindView.heightAnchor, multiplier: 0.5)
        ])

        view.addSubview(zcShieldView)
        zcClampEdges(zcShieldView, to: view)
    }

    private func zcClampEdges(_ child: UIView, to parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        zcMountShieldedStage()
        zcPrepareCanvas()
        zcOpenEntryCanvas()
    }

    deinit {
        guard let zcScriptBridge = zcCanvasWebView?.configuration.userContentController else {
            return
        }
        zcScriptBridge.removeScriptMessageHandler(forName: "handleSkipStore")
        zcScriptBridge.removeScriptMessageHandler(forName: "Close")
        zcScriptBridge.removeScriptMessageHandler(forName: "rechargePay")
        zcScriptBridge.removeScriptMessageHandler(forName: "openBrowser")
    }

    private func zcPrepareCanvas() {
        let protectedContentView = zcShieldView.protectedContentView
        protectedContentView.backgroundColor = .black

        let zcScriptBridge = WKUserContentController()
        zcScriptBridge.add(self, name: "handleSkipStore")
        zcScriptBridge.add(self, name: "Close")
        zcScriptBridge.add(self, name: "rechargePay")
        zcScriptBridge.add(self, name: "openBrowser")

        let zcWebProfile = WKWebViewConfiguration()
        zcWebProfile.allowsInlineMediaPlayback = true
        zcWebProfile.mediaTypesRequiringUserActionForPlayback = []
        zcWebProfile.userContentController = zcScriptBridge

        zcCanvasWebView = WKWebView(frame: .zero, configuration: zcWebProfile)
        zcCanvasWebView.tintColor = .systemBlue
        zcCanvasWebView.navigationDelegate = self
        zcCanvasWebView.uiDelegate = self
        zcCanvasWebView.scrollView.contentInsetAdjustmentBehavior = .never
        zcCanvasWebView.scrollView.bounces = false
        zcCanvasWebView.allowsBackForwardNavigationGestures = true
        zcCanvasWebView.translatesAutoresizingMaskIntoConstraints = false
        protectedContentView.addSubview(zcCanvasWebView)

        launchImageView.image = UIImage(named: zcSigninAssetName)
        launchImageView.contentMode = .scaleAspectFill
        launchImageView.clipsToBounds = true
        launchImageView.translatesAutoresizingMaskIntoConstraints = false
        protectedContentView.addSubview(launchImageView)

        zcCanvasSpinner.color = .white
        zcCanvasSpinner.hidesWhenStopped = true
        zcCanvasSpinner.translatesAutoresizingMaskIntoConstraints = false
        protectedContentView.addSubview(zcCanvasSpinner)

        NSLayoutConstraint.activate([
            zcCanvasWebView.topAnchor.constraint(equalTo: protectedContentView.topAnchor, constant: 0),
            zcCanvasWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            zcCanvasWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            zcCanvasWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            launchImageView.topAnchor.constraint(equalTo: protectedContentView.topAnchor),
            launchImageView.bottomAnchor.constraint(equalTo: protectedContentView.bottomAnchor),
            launchImageView.leadingAnchor.constraint(equalTo: protectedContentView.leadingAnchor),
            launchImageView.trailingAnchor.constraint(equalTo: protectedContentView.trailingAnchor),
            zcCanvasSpinner.centerXAnchor.constraint(equalTo: protectedContentView.centerXAnchor),
            zcCanvasSpinner.centerYAnchor.constraint(equalTo: protectedContentView.centerYAnchor)
        ])
    }

    private func zcOpenEntryCanvas() {
        guard let zcEntryURL = URL(string: zcEntryURLText) else {
            return
        }
        if zcTraceEnabled {
            print(zcEntryURL)
        }

        zcRaiseCurtain()
        zcCanvasStartTick = Int(Date().timeIntervalSince1970 * 1000)
        let zcEntryRequest = URLRequest(url: zcEntryURL)
        zcCanvasWebView.load(zcEntryRequest)
    }

    private func zcRaiseCurtain() {
        launchImageView.isHidden = false
        launchImageView.alpha = 1
        zcFrontloadCurtain()
        zcCanvasSpinner.startAnimating()
    }

    private func zcLowerCurtain(removeLaunchImage: Bool) {
        zcCanvasSpinner.stopAnimating()
        if removeLaunchImage {
            UIView.animate(withDuration: 0.25, animations: {
                self.launchImageView.alpha = 0
            }) { _ in
                self.launchImageView.removeFromSuperview()
            }
        }
    }

    private func zcFrontloadCurtain() {
        let protectedContentView = zcShieldView.protectedContentView
        protectedContentView.bringSubviewToFront(launchImageView)
        protectedContentView.bringSubviewToFront(zcCanvasSpinner)
    }

    func zcSendCanvasTiming() {
        ZCSealedPostClient.zcSendSealedPost(
            path: "opi/v1/talmo/veqrit",
            parameters: ["sdffo": zcCanvasDuration]
        ) { _, _ in }
    }

    func zcOpenRechargeBridge(zcProductId: String, zcOrderCode: String) {
        if zcProductId.isEmpty {
            ZCLoadingCurtain.zcToast("Failed")
            return
        }
        ZCPurchaseLedger.shared.zcOpenOrder(zcProductId: zcProductId, zcOrderCode: zcOrderCode)
    }

    func zcReturnToSignin() {
        guard zcDidFallBackToSignin == false else { return }

        zcDidFallBackToSignin = true
        zcSigninRequestActive = false
        ZCLoadingCurtain.zcFadeSpin()
        zcRemoveLocalText(ZCPersistenceKey.loginToken)
        ZCEntryDirector.shared.zcOverlayWindow?.rootViewController = UINavigationController(rootViewController: ZCSigninBackdropController())
    }
    
    func userContentController(_ zcScriptBridge: WKUserContentController, didReceive zcMessage: WKScriptMessage) {
        switch zcMessage.name {
        case "Close":
            zcReturnToSignin()
        case "rechargePay":
            guard let zcPayload = zcMessage.body as? [String: Any],
                  let zcOrderMark = zcPayload["orderCode"] as? String else { return }

            zcOpenRechargeBridge(zcProductId: zcPayload["batchNo"] as? String ?? "", zcOrderCode: zcOrderMark)
        case "openBrowser":
            guard let zcPayload = zcMessage.body as? [String: Any],
                  let zcURLText = zcPayload["url"] as? String,
                  let zcExternalURL = URL(string: zcURLText) else { return }

            zcOpenExternalURL(zcExternalURL, notify: zcCanvasWebView)
        default:
            break
        }
    }

    func webView(_ zcWebView: WKWebView, didFinish zcNavigation: WKNavigation!) {
        ZCLoadingCurtain.zcFadeSpin()
        zcLowerCurtain(removeLaunchImage: true)
        title = zcWebView.title
        zcCanvasDuration = Int(Date().timeIntervalSince1970 * 1000) - zcCanvasStartTick
        zcSendCanvasTiming()
    }

    func webView(_ zcWebView: WKWebView, didFail zcNavigation: WKNavigation!, withError zcError: Error) {
        zcHandleCanvasFailure(zcError, label: "WebView load failed")
    }
    
    func webView(
        _ zcWebView: WKWebView,
        createWebViewWith zcConfiguration: WKWebViewConfiguration,
        for zcNavigationAction: WKNavigationAction,
        windowFeatures zcWindowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let zcTargetURL = zcNavigationAction.request.url,
           zcIsStoreURL(zcTargetURL) {
            UIApplication.shared.open(zcTargetURL, options: [:], completionHandler: nil)
        }
        return nil
    }

    func webView(_ zcWebView: WKWebView, didFailProvisionalNavigation zcNavigation: WKNavigation!, withError zcError: Error) {
        zcHandleCanvasFailure(zcError, label: "WebView provisional load failed")
    }


    func webView(
        _ zcWebView: WKWebView,
        decidePolicyFor zcNavigationAction: WKNavigationAction,
        decisionHandler zcDecision: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let zcTargetURL = zcNavigationAction.request.url else {
            zcDecision(.allow)
            return
        }

        if zcIsStoreURL(zcTargetURL) {
            UIApplication.shared.open(zcTargetURL, options: [:], completionHandler: nil)
            zcDecision(.cancel)
            return
        }

        if !zcAllowedSchemes.contains(zcTargetURL.scheme ?? "") {
            zcOpenExternalURL(zcTargetURL, notify: zcWebView)
            zcDecision(.cancel)
            return
        }

        zcDecision(.allow)
    }

    

    func webView(
        _ zcWebView: WKWebView,
        requestMediaCapturePermissionFor zcOrigin: WKSecurityOrigin,
        initiatedByFrame zcFrame: WKFrameInfo,
        type zcCaptureType: WKMediaCaptureType,
        decisionHandler zcDecision: @escaping @MainActor (WKPermissionDecision) -> Void
    ) {
        zcDecision(.grant)
    }

    private func zcIsStoreURL(_ zcURL: URL) -> Bool {
        let zcURLText = zcURL.absoluteString
        return zcURLText.hasPrefix("https://apps.apple.com/") || zcURLText.hasPrefix("itms-apps://")
    }

    private func zcOpenExternalURL(_ zcURL: URL, notify zcWebView: WKWebView?) {
        UIApplication.shared.open(zcURL, options: [:]) { [weak zcWebView] zcSucceeded in
            let zcOpenState = zcSucceeded ? "success" : "failed"
            let zcOpenStateScript = """
            window.dispatchEvent(new CustomEvent('nativeOpenState', {
                detail: { state: '\(zcOpenState)', url: '\(zcURL.absoluteString)' }
            }));
            """

            DispatchQueue.main.async {
                zcWebView?.evaluateJavaScript(zcOpenStateScript, completionHandler: nil)
            }
        }
    }

    private func zcHandleCanvasFailure(_ zcError: Error, label: String) {
        ZCLoadingCurtain.zcFadeSpin()
        zcLowerCurtain(removeLaunchImage: false)
        if zcTraceEnabled {
            print("\(label): \(zcError.localizedDescription)")
        }
    }
}
