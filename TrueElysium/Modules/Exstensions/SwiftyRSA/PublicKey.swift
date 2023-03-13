//
//  PublicKey.swift
//  TrueElysium
//
//  Created by Ivan Lele on 03.03.2023.
//

import Foundation
import Security
import SwiftyRSA

extension PublicKey {
    func getModulusAndExponent() -> (Data, Data) {
        let pubAttributes = SecKeyCopyAttributes(self.reference) as! [String: Any]

        let keySize = pubAttributes[kSecAttrKeySizeInBits as String] as! Int

        let pubData  = pubAttributes[kSecValueData as String] as! Data
        var modulus  = pubData.subdata(in: 8..<(pubData.count - 5))
        let exponent = pubData.subdata(in: (pubData.count - 3)..<pubData.count)

        if modulus.count > keySize / 8 {
            modulus.removeFirst(1)
        }
        
        return (modulus, exponent)
    }
    
    
    convenience init(modulus: Data, exponent: Data) throws {
        var _modulus = modulus.bytes
        let _exponent = exponent.bytes
        
        _modulus.insert(0x00, at: 0)
        var modulusEncoded: [UInt8] = []
        modulusEncoded.append(0x02)
        modulusEncoded.append(contentsOf: lengthField(of: _modulus))
        modulusEncoded.append(contentsOf: _modulus)

        var exponentEncoded: [UInt8] = []
        exponentEncoded.append(0x02)
        exponentEncoded.append(contentsOf: lengthField(of: _exponent))
        exponentEncoded.append(contentsOf: _exponent)
        
        var sequenceEncoded: [UInt8] = []
        sequenceEncoded.append(0x30)
        sequenceEncoded.append(contentsOf: lengthField(of: (modulusEncoded + exponentEncoded)))
        sequenceEncoded.append(contentsOf: (modulusEncoded + exponentEncoded))
        
        let keyData = Data(sequenceEncoded)
        
        let keySize = (modulus.count * 8)

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: keySize
        ]

        let publicKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, nil)
        
        try self.init(reference: publicKey!)
    }
}

func lengthField(of valueField: [UInt8]) -> [UInt8] {
    var count = valueField.count

    if count < 128 {
        return [ UInt8(count) ]
    }

    let lengthBytesCount = Int((log2(Double(count)) / 8) + 1)
    let firstLengthFieldByte = UInt8(128 + lengthBytesCount)

    var lengthField: [UInt8] = []
    for _ in 0..<lengthBytesCount {
        let lengthByte = UInt8(count & 0xff)
        lengthField.insert(lengthByte, at: 0)
        count = count >> 8
    }

    lengthField.insert(firstLengthFieldByte, at: 0)

    return lengthField
}
