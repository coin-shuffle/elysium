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
import CryptoSwift

let LIMIT = BigUInt(stringLiteral: "115792089237316195423570985008687907853269984665640564039457584007913129639936")

public class EthereumClient {
    public let client: Web3
    public var user: EthereumPrivateKey?
    public let erc20: GenericERC20Contract
    public let utxoStorage: UTXOStorageContract
    public var lastNonce: EthereumQuantity? = nil
    public let logger = Logger()
    public let networkID: EthereumQuantity
    
    public init(netCfg: NetConfig) throws {
        let client = Web3(rpcURL: netCfg.httpProviderURL)
        
        let erc20 = GenericERC20Contract(
            address: nil,
            eth: client.eth
        )
        let utxoStorage = UTXOStorageContract(
            address: try EthereumAddress(hex: netCfg.utxoStorageAddress, eip55: true),
            eth: client.eth
        )
        
        self.client = client
        self.erc20 = erc20
        self.utxoStorage = utxoStorage
        self.networkID = EthereumQuantity(quantity: try BigUInt(netCfg.networkID))
    }
}

public extension EthereumClient {
    func getGasPrice() async throws -> EthereumQuantity {
        return try await client.eth.gasPrice().async()
    }
    
    func getNonce() async throws -> EthereumQuantity {
        var txCount = try await client.eth.getTransactionCount(
            address: user!.address,
            block: .latest
        ).async()
        
        if lastNonce == nil {
            lastNonce = EthereumQuantity(quantity: txCount.quantity+1)
            return txCount
        }
        
        if lastNonce!.quantity > txCount.quantity {
            txCount = EthereumQuantity(quantity: txCount.quantity + (lastNonce!.quantity - txCount.quantity))
        }
        
        lastNonce = EthereumQuantity(quantity: txCount.quantity+1)
        return txCount
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

extension EthereumClient {
    struct WithdrawSignature: ABIEncodable {
        let id: BigUInt
        let receiver: EthereumAddress
        
        func abiEncode(dynamic: Bool) -> String? {
            return try? ABI.encodeParameter(.tuple(.uint(id), .address(receiver)))
        }
        
        func abiEncodePacked() -> String? {
            let rawID = id.makeBytes()
            
            let encodedID: [UInt8] = Array(repeating: 0, count: 32-rawID.count) + rawID
            let encodedAddress: [UInt8] = receiver.rawAddress
            
            return (encodedID + encodedAddress).toHexString()
        }
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
    
    func listUTXOsByAddress(
        owner: EthereumAddress,
        offset: BigUInt,
        limit: BigUInt
    ) async throws -> [UTXOStorageContract.UTXO] {
        let values = try await utxoStorage.listUTXOsByAddress(owner: owner, offset: offset, limit: limit).call().async()
        return UTXOStorageContract.UTXO.getUTXOsFromAny(values: values["UTXOs"]!)
    }
    
    func createUTXOs(
        tokenStore: TokenStore,
        from tokenContractAddress: EthereumAddress,
        amounts: [BigUInt]
    ) async throws -> [UTXO] {
        erc20.address = tokenContractAddress
        defer {
            erc20.address = nil
        }
        
        let _gasPrice = try await getGasPrice()
        
        guard let approveTx = erc20.approve(spender: utxoStorage.address!, value: amounts.reduce(0, +)).createTransaction(
            nonce: try await getNonce(),
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
        
        var outputs: [UTXOStorageContract.Output] = []
        for amount in amounts {
            outputs.append(
                UTXOStorageContract.Output(
                    amount: amount,
                    owner: self.user!.address
                )
            )
        }
        
        guard let depositTx = utxoStorage.deposit(
            token: tokenContractAddress,
            outputs: outputs
        ).createTx(
            nonce: try await getNonce(),
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
        
        let signedApproveTx = try approveTx.sign(with: user!, chainId: networkID)
        let approveTxHash = try await client.eth.sendRawTransaction(transaction: signedApproveTx).async()
        
        print("Approve Tx Hash: \(approveTxHash.hex())")
        try await waitTxSuccess(txHash: approveTxHash)
        
        let utxosLength = try await getUTXOsLength()
        
        let signedDepositTx = try depositTx.sign(with: self.user!, chainId: networkID)
        let depositTxHash = try await client.eth.sendRawTransaction(transaction: signedDepositTx).async()
        
        print("Deposit Tx Hash: \(depositTxHash.hex())")
        try await waitTxSuccess(txHash: depositTxHash)
        
        let utxos = try await listUTXOsByAddress(
            owner: user!.address,
            offset: utxosLength-1,
            limit: LIMIT
        )
        
        if utxos.isEmpty {
            throw EthereumClientError.txFailed
        }
        let token = try await tokenStore.getToken(tokenContractAddress)
        
        var createdUTXOs: [UTXO] = []
        for (index, amount) in amounts.enumerated() {
            createdUTXOs.append(
                UTXO(
                    ID: utxos[utxos.count-(amounts.count-index)].id,
                    token: tokenContractAddress,
                    amount: amount,
                    owner: user!.address,
                    name: token.name,
                    symbol: token.symbol,
                    status: .created
                )
            )
        }
        
        return createdUTXOs
    }
    
    func withdraw(
        id: BigUInt,
        to: EthereumAddress
    ) async throws {
        let gasPrice = try await getGasPrice()
        
        guard let encodedData = WithdrawSignature(
            id: id,
            receiver: to
        ).abiEncodePacked() else {
            throw EthereumClientError.failedToEncodeWithdrawSignatureData
        }
        
        let signature = try signMsg(data: Data(encodedData.hexToBytes()))
        
        print("Signature: \(signature.toHexString())")
        
        let input = UTXOStorageContract.Input(
            id: id,
            signature: signature
        )
        
        guard let depositTx = utxoStorage.withdraw(
            to: to,
            input: input
        ).createTx(
            nonce: try await getNonce(),
            gasPrice: EthereumQuantity(quantity: gasPrice.quantity + 50.gwei),
            maxFeePerGas: EthereumQuantity(quantity: gasPrice.quantity + 100.gwei),
            maxPriorityFeePerGas: EthereumQuantity(quantity: 3.gwei),
            gasLimit: 3000000,
            from: self.user!.address,
            value: 0,
            accessList: [:],
            transactionType: .legacy
        ) else {
            throw EthereumClientError.failedToCreateTx
        }
        
        let signedDepositTx = try depositTx.sign(
            with: user!,
            chainId: networkID
        )
        let depositTxHash = try await client.eth.sendRawTransaction(
            transaction: signedDepositTx
        ).async()

        print("Withdraw Tx Hash: \(depositTxHash.hex())")
        try await waitTxSuccess(txHash: depositTxHash)
    }
    
    fileprivate func signMsg(data: Data) throws -> Data {
        print("Encoded data: \(data.toHexString())")
        
        let hashedMsg = SHA3(variant: .keccak256).calculate(for: data.makeBytes())
        
        print("Hashed Message: \(hashedMsg.toHexString())")
        
        let prefix = "19457468657265756d205369676e6564204d6573736167653a0a3332".hexToBytes()
        
        print("Prefix: \(prefix.toHexString())");
        
        let signMsg = SHA3(variant: .keccak256).calculate(for: prefix+hashedMsg)
        
        print("Sign Msg: \(signMsg.toHexString())")
        
        let (v, r, s) = try user!.sign(hash: signMsg)
        
        return Data(r+s+[Byte(v+27)])
    }
}
