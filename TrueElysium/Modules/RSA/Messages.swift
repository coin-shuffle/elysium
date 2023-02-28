//
//  Messages.swift
//  TrueElysium
//
//  Created by Ivan Lele on 28.02.2023.
//

import CryptoSwift
import Web3

let ENCRYPTING_CHUNK_SIZE2048PUB_KEY: Int = 126;
let ENCRYPTED_CHUNK_SIZE2048PUB_KEY: Int = 256;

public struct EncryptionResult {
    public let encryptedMessage: Bytes
    public let nonce: Bytes
}

public struct DecryptionResult {
    public let DecryptedMessage: Bytes
    public let nonce: Bytes
}

public func encryptByChunks(
    message: Bytes,
    publicRsaKey: RSA,
    nonce: Bytes
) throws -> EncryptionResult {
    var resultMessage = Bytes()
    var messageBuffer = message
    
    while !messageBuffer.isEmpty {
        var chunk = messageBuffer
        
        if chunk.count >= ENCRYPTING_CHUNK_SIZE2048PUB_KEY {
            chunk = Bytes(chunk.prefix(ENCRYPTING_CHUNK_SIZE2048PUB_KEY))
            messageBuffer = Bytes(messageBuffer.suffix(from: ENCRYPTING_CHUNK_SIZE2048PUB_KEY))
        } else {
            messageBuffer.removeAll()
        }
        
        let encryptedChunk = try publicRsaKey.encrypt(chunk)
        
        resultMessage.append(contentsOf: encryptedChunk)
    }
    
    return EncryptionResult(encryptedMessage: Bytes(), nonce: Bytes([]))
}
