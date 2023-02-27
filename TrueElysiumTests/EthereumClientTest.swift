//
//  EthereumClientTest.swift
//  TrueElysium
//
//  Created by Ivan Lele on 21.02.2023.
//

import XCTest
import Web3
import Web3ContractABI
import Web3PromiseKit


final class EthereumClientTest: XCTestCase {
    private var ethereumClient: EthereumClient!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.ethereumClient = try EthereumClient(
            privateKey: "c70f720a396a8dafa16da1a3bddefe70f22b089a7c821e3595765d14de0f377f",
            utxoStorageContractAddress: try! EthereumAddress(hex: "0x4C0d116d9d028E60904DCA468b9Fa7537Ef8Cd5f", eip55: true)
        )
        
        print("Gas price: \(ethereumClient.gasPrice!)")
        print("Funds: \(try! ethereumClient.client.eth.getBalance(address: ethereumClient.user.address, block: .latest).wait())")
    }

    override func tearDownWithError() throws {}

    func testGetNameAndSymbol() throws {
        let contractAddress = try EthereumAddress(hex: "0x7057cB3cB70e1d4a617A0DED65353553af8d5976", eip55: true)
        print("contract address: \(contractAddress.hex(eip55: false))")
        
        var name: String, symbol: String
        (name, symbol) = try ethereumClient.getETC20NameAndSymbol(contractAddress)
        
        assert(name == "Ibrahim" && symbol == "KEK", "Invalid name and symbol of the token")
        print("Token name: \(name), Token symbol: \(symbol)")
    }
    
    func testCreateUTXO() throws {
        let contractAddress = try EthereumAddress(hex: "0x7057cB3cB70e1d4a617A0DED65353553af8d5976", eip55: true)
        
        let amount = BigUInt(5)
        let utxo = try ethereumClient.createUTXO(from: contractAddress, amount: amount)
        
        assert(utxo.id == ethereumClient.userUTXOs.count-1, "UTXO ERROR: Invalid ID")
        assert(utxo.token == contractAddress, "UTXO ERROR: Invalid token")
        assert(utxo.amount == amount, "UTXO ERROR: Invalid amount")
        assert(utxo.owner == ethereumClient.user.address, "UTXO ERROR: Invalid owner")
        assert(utxo.name == "Ibrahim", "UTXO ERROR: Invalid name")
        assert(utxo.symbol == "KEK", "UTXO ERROR: Invalid symbol")
        assert(utxo.status == .created, "UTXO ERROR: Invalid status")
        
        print("UTXO: [id: \(utxo.id), token: \(utxo.token), amount: \(utxo.amount), owner: \(utxo.owner), name: \(utxo.name), symbol: \(utxo.symbol), status: \(utxo.status.description)]")
    }
    
    func testOutputConverible() throws {
        let token = try EthereumAddress(hex: "0xf90699245de9a7C70725954Baf0E285fD18AdA02", eip55: true)
        
        let output = UTXOStorageContract.Output(
            amount: 5,
            owner: try! EthereumAddress(hex: "0xE86C4A45C1Da21f8838a1ea26Fc852BD66489ce9", eip55: true)
        )
        
        let encoded = try ABI.encodeParameter(type: .tuple([.address, .uint256]), value: output)
        print("Encoded tuple: \(encoded)")
              
        let decodedOutput = UTXOStorageContract.Output(hexString: encoded)!
        assert(output.owner == decodedOutput.owner, "Data corruption")
        print("owner: \(decodedOutput.owner.hex(eip55: false)), amount: \(decodedOutput.amount)")
        
        
        let encodedArray = try ABI.encodeParameter(type: .array(type: .tuple([.uint256, .address]), length: 1), value: [output])
        print("Encoded array: \(encodedArray)")
        
        let decodedArray = [UTXOStorageContract.Output](hexString: encodedArray, length: 1)!
        assert(output.owner == decodedArray.first?.owner, "Data corruption")
        print("Decoded array: \(decodedArray)")
        
        let encodedParameters = try ABI.encodeParameters(
            types: [.address, .array(type: .tuple([.uint256, .address]), length: 1)],
            values: [token, [output]]
        )
        print("Encoded Parameters: \(encodedParameters)")
        
        let ethereumData = try EthereumData(encodedParameters)
        print("Ethereum data: \(ethereumData)")
    }
    
    func testFunctionEncoding() throws {
        let contractAddress = try EthereumAddress(hex: "0xf90699245de9a7C70725954Baf0E285fD18AdA02", eip55: true)
        
        let invocation = ethereumClient.utxoStorage.deposit(
            token: contractAddress,
            outputs: [UTXOStorageContract.Output(amount: 5, owner: ethereumClient.user.address)]
        )
        
        guard let hexString = try? ABI.encodeFunctionCall(invocation) else {
            assertionFailure("failed to encode a function call")
            return
        }
        print("Hex of an invocation: \(hexString)")
        
        print("Filtered hex of an invocation: \(hexString.removeSubstringExceptFirst("0x"))")
        
        guard let data = try? EthereumData(ethereumValue: hexString.removeSubstringExceptFirst("0x")) else {
            assertionFailure("failed to encode data")
            return
        }
        
        print("Data: \(data)")
        
        print("Data hex: \(data.hex())")
        
        guard let tx = invocation.createTx(
            nonce: 0,
            gasPrice: 0,
            maxFeePerGas: nil,
            maxPriorityFeePerGas: nil,
            gasLimit: 300000,
            from: ethereumClient.user.address,
            value: 0,
            accessList: [:],
            transactionType: .legacy
        ) else {
            assertionFailure("Failed to create a tx")
            return
        }
        
        print("Tx: \(tx)")
    }
    
    func testUTXOsFetch() throws {
        let semaphore = DispatchSemaphore(value: 0)
        var err: Error?
        var flag = true
        while flag {
            firstly {
                ethereumClient.utxoStorage.listUTXOsByAddress(
                    owner: ethereumClient.user.address,
                    offset: BigUInt(ethereumClient.userUTXOs.count),
                    limit: 5
                ).call()
            }.done(on: ethereumClient.queue) { values in
                let utxos = UTXOStorageContract.UTXO.getUTXOsFromAny(values: values["UTXOs"]!)
                if utxos.isEmpty {
                    flag = false
                }
                
                self.ethereumClient.userUTXOs.append(contentsOf: utxos)
            }.catch(on: ethereumClient.queue) { error in
                err = error
            }.finally(on: ethereumClient.queue) {
                semaphore.signal()
            }; semaphore.wait()
            if err != nil {
                throw err!
            }
        }
        
        print("UTXOs: \(ethereumClient.userUTXOs)")
    }
}