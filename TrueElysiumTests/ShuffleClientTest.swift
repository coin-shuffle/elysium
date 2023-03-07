//
//  ShuffleClientTest.swift
//  TrueElysiumTests
//
//  Created by Ivan Lele on 05.03.2023.
//

import XCTest
import Web3

final class ShuffleClientTest: XCTestCase {
    var client: ShuffleClient!
    let privateEthKey = try! EthereumPrivateKey(
        hexPrivateKey: ""
    )
    
    override func setUpWithError() throws {
        let store = UTXOStore()
        
        store.utxos.append(contentsOf:
            [
                UTXO(
                    id: 0,
                    token: try EthereumAddress(hex: "0x7057cB3cB70e1d4a617A0DED65353553af8d5976", eip55: true),
                    amount: 5,
                    owner: try EthereumAddress(hex: "0xE86C4A45C1Da21f8838a1ea26Fc852BD66489ce9", eip55: true),
                    name: "Ibrahim",
                    symbol: "Kek"
                ),
                UTXO(
                    id: 1,
                    token: try EthereumAddress(hex: "0x7057cB3cB70e1d4a617A0DED65353553af8d5976", eip55: true),
                    amount: 5,
                    owner: try EthereumAddress(hex: "0xE86C4A45C1Da21f8838a1ea26Fc852BD66489ce9", eip55: true),
                    name: "Ibrahim",
                    symbol: "Kek"
                ),
                UTXO(
                    id: 2,
                    token: try EthereumAddress(hex: "0x7057cB3cB70e1d4a617A0DED65353553af8d5976", eip55: true),
                    amount: 5,
                    owner: try EthereumAddress(hex: "0xE86C4A45C1Da21f8838a1ea26Fc852BD66489ce9", eip55: true),
                    name: "Ibrahim",
                    symbol: "Kek"
                )
            ]
        )
        
        client = try ShuffleClient(
            grpcHost: "3.23.147.9",
            port: 8080,
            node: Node(
                utxoStore: store
            )
        )
    }
    override func tearDownWithError() throws {}
    
    func testAllAtOnce() async throws {
        let task1 = Task {
            try await testParticipant(utxoID: 0)
        }
        
        try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
        
        let task2 = Task {
            try await testParticipant(utxoID: 1)
        }
        
        try await Task.sleep(nanoseconds: UInt64(5 * Double(NSEC_PER_SEC)))
        
        let task3 = Task {
            try await testParticipant(utxoID: 2)
        }
        
        _ = await task1.result
        _ = await task2.result
        _ = await task3.result
    }
    
    
    func testParticipant(utxoID: BigUInt) async throws {
        try await client.initRoom(
            utxoID: utxoID,
            outputAddress: EthereumAddress(hex: "0xd35c0a2d081493467196A01769B63616F8D8805f", eip55: true),
            privateEthKey: privateEthKey
        )
        try await client.joinRoom(utxoID: utxoID)
        try await client.waitShuffle(utxoID: utxoID)
        try await client.connectRoom(utxoID: utxoID)
    }
    
    func testEncoding() throws {
        print("ID: \(BigUInt(0).hexEncode)")
    }
    
    func testSign() throws {
        let msg: [UInt8] = [48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 50, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 53, 211, 92, 10, 45, 8, 20, 147, 70, 113, 150, 160, 23, 105, 182, 54, 22, 248, 216, 128, 95, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 53, 211, 92, 10, 45, 8, 20, 147, 70, 113, 150, 160, 23, 105, 182, 54, 22, 248, 216, 128, 95, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 53, 211, 92, 10, 45, 8, 20, 147, 70, 113, 150, 160, 23, 105, 182, 54, 22, 248, 216, 128, 95]
        
        print("Signature: \(try ecdsaTXSign(msg: msg, privateKey: privateEthKey))")
    }
}
