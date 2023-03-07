//
//  RSACrypto.swift
//  TrueElysium
//
//  Created by Ivan Lele on 01.03.2023.
//

import SwiftyRSA
import Security
import Web3

enum RsaCrypto: Error {
    case invalidMsgErr
    case invalidNonceErr
    case invalidPemErr
    case failedToEncryptErr
    case failedToDecryptErr
    case invalidKeyErr
    case failedToSign
    
    static func getError(op: UInt8) -> RsaCrypto {
        switch op {
        case 1:
            return .invalidMsgErr
        case 2:
            return .invalidNonceErr
        case 3:
            return .invalidPemErr
        case 4:
            return .failedToEncryptErr
        case 5:
            return .failedToDecryptErr
        case 6:
            return .invalidKeyErr
        case 7:
            return .failedToSign
        default:
            fatalError("A unreachable error")
        }
    }
}

public func rsaEncrypt(msg: [UInt8], publicKey: PublicKey, nonce: [UInt8]) throws -> [UInt8] {
    let result: UnsafePointer<CChar>? = rust_encrypt(
        String(bytes: msg.toHexString().bytes, encoding: .utf8),
        String(bytes: nonce.toHexString().bytes, encoding: .utf8),
        String(bytes: try publicKey.pemString().bytes, encoding: .utf8)
    )
    
    let swiftResult = String(cString: result!)
    rust_free(UnsafeMutablePointer(mutating: result))
    
    if swiftResult.bytes.count == 1 {
        throw RsaCrypto.getError(op: swiftResult.bytes[0])
    }
    
    return swiftResult.hexToBytes()
}

public func rsaDecrypt(msg: [UInt8], privateKey: PrivateKey) throws -> [UInt8] {
    let result: UnsafePointer<CChar>? = rust_decrypt(
        String(bytes: msg.toHexString().bytes, encoding: .utf8),
        String(bytes: try privateKey.pemString().bytes, encoding: .utf8)
    )
    
    let swiftResult = String(cString: result!)
    rust_free(UnsafeMutablePointer(mutating: result))
    
    
    if swiftResult.bytes.count == 1 {
        throw RsaCrypto.getError(op: swiftResult.bytes[0])
    }

    return swiftResult.hexToBytes()
}

public func newRandomRSAPrivateKey(keyLength: UInt64) throws -> PrivateKey {
    let attributes: [CFString: Any] = [
        kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits: keyLength,
        kSecPrivateKeyAttrs: [
            kSecAttrIsPermanent: true,
            kSecAttrLabel: "distributed.lab",
            kSecAttrApplicationTag:
                "com.coin.shuffle.keys.distributed.lab".data(using: .utf8) as Any
        ]
    ]
     
    var error: Unmanaged<CFError>?
    guard let secKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        throw error!.takeRetainedValue() as Error
    }
    
    return try PrivateKey(reference: secKey)
}
