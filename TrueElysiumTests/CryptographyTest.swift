//
//  RSA.swift
//  TrueElysiumTests
//
//  Created by Ivan Lele on 28.02.2023.
//

import XCTest
import CryptoSwift

final class CryptographyTest: XCTestCase {
    var privateRSAKey: RSA!
    
    override func setUpWithError() throws {
        guard let publicKeyData = Data(base64Encoded: """
            MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAveBAMytUanlMXbGrBFkw
            o4cicCC7Xb6CxsqZE2YkhRg4hpcilGq7ZsZ1NsNfUzu18/6XieibFaUngBRzQxLT
            QB6+Un9fhDVgeuYNWwqzouRaVRLByHjli8JZRoYXB1Aaz4zhDIa+SexAbyLrn6nD
            /rxO0tjcn9PhzvCTjyS4KpH3sXYv+BoD9RCFZ59bKK7hvdnoLb42nLfe/SoatcD4
            o0LM1qWxgBJaNba3JUTVHZaWZ6i82yUNXe8aKktEDfVvUk3jCfA/uRwMmVcm8wtX
            WbVfeDe8RFrLE+KizzaulAZPvlIzromK1MYEj5/KxjA3J3eKhDcERhMfau4K1o0e
            NwIDAQAB
            """) else {
            fatalError("Failed to encode the public key")
        }
        
        // Decode the public key data into a `SecKey` object
        var error: Unmanaged<CFError>?
        let publicKey: SecKey = SecKeyCreateWithData(publicKeyData as CFData, [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic
        ] as CFDictionary, &error)!
        if error != nil {
            fatalError("Error: \(error.debugDescription)")
        }
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
