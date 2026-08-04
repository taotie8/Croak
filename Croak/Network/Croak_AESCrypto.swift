import CryptoKit
import Foundation
import Security

@objc(Croak_AESCrypto)
final class Croak_AESCrypto: NSObject {
    private static let errorDomain = "CroakAESCryptoErrorDomain"
    private static let ivLength = 12
    private static let tagLength = 16

    @objc(croak_encryptJSONObject:keyData:error:)
    class func croak_encryptJSONObject(_ object: Any,
                                       keyData: Data,
                                       error: NSErrorPointer) -> NSDictionary? {
        guard keyData.count == 32 else {
            setError(error, code: 1001, message: "AES-256-GCM key must be 32 bytes.")
            return nil
        }

        guard JSONSerialization.isValidJSONObject(object) else {
            setError(error, code: 1002, message: "Request object is not valid JSON.")
            return nil
        }

        do {
            let plaintext = try JSONSerialization.data(withJSONObject: object, options: [])
            let iv = try randomData(length: ivLength)
            let nonce = try AES.GCM.Nonce(data: iv)
            let sealedBox = try AES.GCM.seal(plaintext, using: SymmetricKey(data: keyData), nonce: nonce)
            let encryptedData = sealedBox.ciphertext + sealedBox.tag

            return [
                "iv": iv.base64EncodedString(),
                "data": encryptedData.base64EncodedString()
            ]
        } catch let caughtError {
            setError(error, code: 1003, message: caughtError.localizedDescription)
            return nil
        }
    }

    @objc(croak_decryptEnvelope:keyData:error:)
    class func croak_decryptEnvelope(_ envelope: NSDictionary,
                                     keyData: Data,
                                     error: NSErrorPointer) -> Any? {
        guard keyData.count == 32 else {
            setError(error, code: 1001, message: "AES-256-GCM key must be 32 bytes.")
            return nil
        }

        guard let ivString = envelope["iv"] as? String,
              let dataString = envelope["data"] as? String,
              let iv = Data(base64Encoded: ivString),
              let encryptedData = Data(base64Encoded: dataString),
              encryptedData.count >= tagLength else {
            setError(error, code: 1004, message: "Encrypted response format is invalid.")
            return nil
        }

        do {
            let nonce = try AES.GCM.Nonce(data: iv)
            let ciphertext = encryptedData.prefix(encryptedData.count - tagLength)
            let tag = encryptedData.suffix(tagLength)
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
            let plaintext = try AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))

            if plaintext.isEmpty {
                return NSNull()
            }

            if let jsonObject = try? JSONSerialization.jsonObject(with: plaintext, options: []) {
                return jsonObject
            }

            if let string = String(data: plaintext, encoding: .utf8) {
                return string
            }

            return plaintext as NSData
        } catch let caughtError {
            setError(error, code: 1005, message: caughtError.localizedDescription)
            return nil
        }
    }

    private class func randomData(length: Int) throws -> Data {
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes { pointer in
            SecRandomCopyBytes(kSecRandomDefault, length, pointer.baseAddress!)
        }

        if result != errSecSuccess {
            throw NSError(domain: errorDomain, code: 1006, userInfo: [
                NSLocalizedDescriptionKey: "Failed to generate random IV."
            ])
        }

        return data
    }

    private class func setError(_ error: NSErrorPointer, code: Int, message: String) {
        error?.pointee = NSError(domain: errorDomain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message
        ])
    }
}
