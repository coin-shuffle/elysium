//
//  RSA.swift
//  TrueElysiumTests
//
//  Created by Ivan Lele on 28.02.2023.
//

import XCTest
import Web3
import SwiftyRSA

final class CryptographyTest: XCTestCase {
    var privateRSAKey: PrivateKey!
    var publicRSAKey: PublicKey!
    var privateEthereumKey: EthereumPrivateKey!
    
    override func setUpWithError() throws {
        privateRSAKey = try PrivateKey(pemEncoded: """
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAkmlRpiW0IU281qG+37u+zKtzSi3d1G+9Jop1IXQl76hOHWqq
3goNT3bQ/2wDNtMnZ6OlhsnDe03rlEUtzCJmLchm0o96pFsMvO2wL2neh9/BBA+J
E0I+OJ5mRihm4v379c939u5TfhnTwyOELIJSjC4zST13wTWvS5M2ZHs35H0Nn7Xh
QIsE3vdYljUh7zCAv6SWuI6ERffkYcqUrKjCzFGQhfNPbS1tzDaiGCDFeY3RYL2d
LyptcwTpC4qlKM5GwEdHKYKqxGRJ4UhTNtPyEcaz4hz1cKkTtIAvzj0JZIkzeJJZ
pmRqgZQvTwhzIx2fHs0ecpJHTe1+MXtYlt+CZQIDAQABAoIBAAqD+/RF8vkNX0m/
Fjl1f4+tpLsoLi2K1PgGq8D6WZsr6Ghed+U4rZoOe5ZMyLJQWh0seMAEj8C0aP4e
NdragaI6KYBoA7P4QiLzo1rUbMIvhOpovzyd3mAsqEXTswgMm+Mcwo3+sgp1imsS
ivSza4Bb9R0GiCpdU7jG2vo+i1YitVk1OTpyZXWtAaMcU1FsQR/5crnxVbdhEoce
TFxCgFOYtP7VKuWn9IAot/GAUVdXtHuIzMCK50dBhWdtKQtmBna7OGJ2cd353q8Q
uw+3yfjznFQdKcBU8Q/Uf8V2uxJcnjpGiIAkNMSnDQMNa7zj94oqdCz9+uu/6yBg
2XQSOEECgYEAydup7thQml4xaxZhVTe2Y9Ty39ITZUeVsOI3Vukdo7kLgU/8FvzW
1A87z9kF7APLSdc1G6/CkQR9o7IzgK1aZTp/OhR4ugPvc/v6ZVIzTs9ypPVtcM06
0Zc7PtIjwJYGmkdN0OCL7YvgP3k171TwOOPASJDsLNLCzhv6YQas8jUCgYEAua56
cA8pnZGNrKne3w8QPvNdbkW1mxDw6v1vs1GAUiOyXcVSOYlBb3klrDfNhQPs2iNh
AVfUpRyGCdo1BCVapx/Euii8eazyG4PEDRY8lRQDYxOLrzJSf9sokq34u1dBkuOr
nCb/N3X1HF9l6k7fjEtd2ojThXmnE+wrwGtJVXECgYEAp0ZuMux1Fwc5gpmAPSM2
9NHSFqI6ynIg3P0JiO8TTcqZeyZyLAaIbCDXmu0oWCXov58kdnYXER+ckhupTFfb
kgmAxvuR8+ww8Xd9T5tnw0ZrpcFwWMrplCfzw6JWWFC61fyCwrZhno+MXG0wwc0s
aKhrfncCED7zieNrgB4NEYUCgYEAn/eWWiZl9u7n/IIYlVk36NPngVIjJCXTONAA
xJ8Jizpft3OA5DrAmhXoA9fLgrYf/sqODwcpFtpdC+3m0NyRnfu7k5n2zmjV6Ch7
5b5rkQ+930R+igAznR0ldkDVUijZQIBOX2glZhWEht4VQmiTJR3lDJnmiU6GR56n
Ds4fTrECgYBctVh/fUap/XtIO0IBQXeVOfhWM8ScrMiSskacls/SQL0sIx3pe/8/
zLmaPxW9smbYJMN+5I6hZwIfAzeC2/uNxJay9b1qsEfISalGbbjXpM7Ui6TLBBUW
s2RQwADGPXRVVl55ylgqVw1Q6tvvkj+uAB8NhXTCZ1pJd9192pACcg==
-----END RSA PRIVATE KEY-----
""")
        publicRSAKey = privateRSAKey.publicKey
        privateEthereumKey = try EthereumPrivateKey(
            hexPrivateKey: ""
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRSAEcryptionWithNonce() throws {
        let data = try Data("hello world")

        print("Data: \(data.bytes)")
        
        let encryptedMsg = try rsaEncrypt(
            msg: data.bytes,
            publicKey: publicRSAKey,
            nonce: Array(repeating: UInt8(1), count: 32)
        )
        
        print("Encrypted message: \(encryptedMsg)")
    }
    
    func testRSADecryption() throws {
        let encryptedMsg = try rsaEncrypt(
            msg: try Data("hello world").bytes,
            publicKey: publicRSAKey,
            nonce: Array(repeating: UInt8(1), count: 32)
        )
        
        let decryptedMsg = try rsaDecrypt(
            msg: encryptedMsg,
            privateKey: privateRSAKey
        )
    
        print("Decrypted message: \(decryptedMsg)")
    }
    
    func testEtherSigning() throws {
        let msg = "hello world".bytes
        
        let signedMsg = try ecdsaSign(msg: msg, privateKey: privateEthereumKey)
        print("Signed message: \(signedMsg)")
    }
    
    func testConvertable() throws {
        print("Public key: \(privateRSAKey.publicKey)")
    }
    
    func testModulusAndExponent() throws {
        let (modulus, exponent) = publicRSAKey.getModulusAndExponent()
        
        print("Modulus: \(modulus.toHexString())")
        print("Exponent: \(exponent.toHexString())")
        
        let publicKey = try PublicKey(modulus: modulus, exponent: exponent)
        print("Public key: \(try publicKey.pemString())")
    }
}
