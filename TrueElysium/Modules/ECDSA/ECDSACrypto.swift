//
//  ECDSACrypto.swift
//  TrueElysium
//
//  Created by Ivan Lele on 03.03.2023.
//

import Web3

public func ecdsaSign(msg: [UInt8], privateKey: EthereumPrivateKey) throws -> [UInt8] {
    let result: UnsafePointer<CChar>? = rust_sign(
        String(bytes: msg.toHexString().bytes, encoding: .utf8),
        String(bytes: privateKey.makeBytes().toHexString().bytes, encoding: .utf8)
    )
    
    let swiftResult = String(cString: result!)
    rust_free(UnsafeMutablePointer(mutating: result))
    
    if swiftResult.bytes.count == 1 {
        throw RsaCrypto.getError(op: swiftResult.bytes[0])
    }
    
    return swiftResult.hexToBytes()
}

public func ecdsaTXSign(msg: [UInt8], privateKey: EthereumPrivateKey) throws -> [UInt8] {
    let result: UnsafePointer<CChar>? = rust_tx_sign(
        String(bytes: msg.toHexString().bytes, encoding: .utf8),
        String(bytes: privateKey.makeBytes().toHexString().bytes, encoding: .utf8)
    )
    
    let swiftResult = String(cString: result!)
    rust_free(UnsafeMutablePointer(mutating: result))
    
    if swiftResult.bytes.count == 1 {
        throw RsaCrypto.getError(op: swiftResult.bytes[0])
    }
    
    return swiftResult.hexToBytes()
}
