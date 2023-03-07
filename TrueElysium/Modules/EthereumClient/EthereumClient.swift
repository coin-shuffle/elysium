//
//  EthereumClient.swift
//  TrueElysium
//
//  Created by Ivan Lele on 21.02.2023.
//

import os
import Foundation
import Web3
import Web3ContractABI
import Web3PromiseKit
import Collections

let LIMIT = BigUInt(stringLiteral: "115792089237316195423570985008687907853269984665640564039457584007913129639936")

public class EthereumClient {
    public let client: Web3
    public var user: EthereumPrivateKey?
    public let erc20: GenericERC20Contract
    public let utxoStorage: UTXOStorageContract
    public let logger = Logger()
    public var queue = DispatchQueue.global(qos: .default)
    
    public init(utxoStorageContractAddress: EthereumAddress) throws {
        let rpcURL = "https://goerli.infura.io/v3/cb621ec4047444bd91487c018d21f733"
        let client = Web3(rpcURL: rpcURL)
        
        let erc20 = GenericERC20Contract(address: nil, eth: client.eth)
        let utxoStorage = UTXOStorageContract(address: utxoStorageContractAddress, eth: client.eth)
        
        self.client = client
        self.erc20 = erc20
        self.utxoStorage = utxoStorage
    }
    
}

public extension EthereumClient {
    func getGasPrice() async throws -> EthereumQuantity {
        return try await client.eth.gasPrice().async()
    }
    
    func getNonce() async throws -> EthereumQuantity {
        return try await client.eth.getTransactionCount(
            address: user!.address,
            block: .latest
        ).async()
    }
}

public extension EthereumClient {
    func waitTxSuccess(txHash: EthereumData, each intervalInSeconds: UInt64 = 3) async throws {
        while true {
            try await Task.sleep(nanoseconds: intervalInSeconds * NSEC_PER_SEC)
            let receipt = try? await self.client.eth.getTransactionReceipt(transactionHash: txHash).async()
            if let status = receipt?.status {
                if status == 1 {
                    return
                }
                
                throw EthereumClientError.txFailed
            }
        }
    }
    
    func isContract(_ contractAddress: EthereumAddress) async throws -> Bool {
        let code = try await client.eth.getCode(
            address: contractAddress,
            block: .latest
        ).async()
                
        if code.bytes.count == 0 {
            return false
        }
        
        return true
    }
}

public extension EthereumClient {
    func getETC20NameAndSymbol(_ tokenContractAddress: EthereumAddress) async throws -> (String, String) {
        erc20.address = tokenContractAddress
        defer {
            erc20.address = nil
        }
        
        let name = try await erc20.name().call().async()["_name"] as? String
        let symbol = try await erc20.symbol().call().async()["_symbol"] as? String
        
        return (name ?? "Token", symbol ?? "SYM")
    }
    
    func getUTXOsLength() async throws -> BigUInt {
        return (try await utxoStorage.getUTXOsLength().call().async()["length"] as? BigUInt)!
    }
    
    func listUTXOsByAddress(owner: EthereumAddress, offset: BigUInt, limit: BigUInt) async throws -> [UTXOStorageContract.UTXO] {
        let values = try await utxoStorage.listUTXOsByAddress(owner: owner, offset: offset, limit: limit).call().async()
        return UTXOStorageContract.UTXO.getUTXOsFromAny(values: values["UTXOs"]!)
    }
    
    func createUTXO(from tokenContractAddress: EthereumAddress, amount: BigUInt) async throws -> UTXO {
        erc20.address = tokenContractAddress
        defer {
            erc20.address = nil
        }
        
        let _nonce = EthereumQuantity(quantity: try await getNonce().quantity)
        let _gasPrice = try await getGasPrice()
        
        guard let approveTx = erc20.approve(spender: utxoStorage.address!, value: amount).createTransaction(
            nonce: _nonce,
            gasPrice: EthereumQuantity(quantity: _gasPrice.quantity + 50.gwei),
            maxFeePerGas: EthereumQuantity(quantity: _gasPrice.quantity + 100.gwei),
            maxPriorityFeePerGas: EthereumQuantity(quantity: 3.gwei),
            gasLimit: 3000000,
            from: user!.address,
            value: 0,
            accessList: [:],
            transactionType: .legacy
        ) else {
            throw EthereumClientError.failedToCreateTx
        }
        
        guard let depositTx = utxoStorage.deposit(
            token: tokenContractAddress,
            outputs: [UTXOStorageContract.Output(amount: amount, owner: self.user!.address)]
        ).createTx(
            nonce: EthereumQuantity(quantity: _nonce.quantity + 1),
            gasPrice: EthereumQuantity(quantity: _gasPrice.quantity + 50.gwei),
            maxFeePerGas: EthereumQuantity(quantity: _gasPrice.quantity + 100.gwei),
            maxPriorityFeePerGas: EthereumQuantity(quantity: 3.gwei),
            gasLimit: 3000000,
            from: self.user!.address,
            value: 0,
            accessList: [:],
            transactionType: .legacy
        ) else {
            throw EthereumClientError.failedToCreateTx
        }
        
        let signedApproveTx = try approveTx.sign(with: user!, chainId: 5)
        let approveTxHash = try await client.eth.sendRawTransaction(transaction: signedApproveTx).async()
        
        print("Approve Tx Hash: \(approveTxHash)")
        try await waitTxSuccess(txHash: approveTxHash)
        
        let utxosLength = try await getUTXOsLength()
        
        let signedDepositTx = try depositTx.sign(with: self.user!, chainId: 5)
        let depositTxHash = try await client.eth.sendRawTransaction(transaction: signedDepositTx).async()
        
        print("Deposit Tx Hash: \(depositTxHash)")
        try await waitTxSuccess(txHash: depositTxHash)
        
        let utxos = try await listUTXOsByAddress(
            owner: user!.address,
            offset: utxosLength-1,
            limit: LIMIT
        )
        
        if utxos.isEmpty {
            throw EthereumClientError.txFailed
        }
        
        var name: String, symbol: String
        (name, symbol) = try await getETC20NameAndSymbol(tokenContractAddress)
        
        return UTXO(
            ID: utxos.last!.id,
            token: tokenContractAddress,
            amount: amount,
            owner: user!.address,
            name: name,
            symbol: symbol,
            status: .created
        )
    }
}
