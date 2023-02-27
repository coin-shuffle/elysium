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

public class EthereumClient {
    public let client: Web3
    public var user: EthereumPrivateKey?
    public var userUTXOs: [UTXOStorageContract.UTXO]
    public let erc20: GenericERC20Contract
    public let utxoStorage: UTXOStorageContract
    public let logger = Logger()
    public var queue = DispatchQueue.global(qos: .default)
    
    public init(utxoStorageContractAddress: EthereumAddress) throws {
        let rpcURL = "https://goerli.infura.io/v3/d009354476b140008dd04c741c00341b"
        let client = Web3(rpcURL: rpcURL)
        
        let erc20 = GenericERC20Contract(address: nil, eth: client.eth)
        let utxoStorage = UTXOStorageContract(address: utxoStorageContractAddress, eth: client.eth)
        
        self.client = client
        self.erc20 = erc20
        self.utxoStorage = utxoStorage
        self.userUTXOs = []
        
        guard _checkConnection(client: client) else {
            throw EthereumClientError.failedToConnect
        }
    }

    
    private func _checkConnection(client: Web3) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        
        client.clientVersion()
            .done(on: queue) { version in
                self.logger.info("Ethereum client version: \(version)")
                success = true
            }
            .catch(on: queue) { error in
                self.logger.error("An error has occured: \(error)")
            }
            .finally(on: queue) {
                semaphore.signal()
            }; semaphore.wait()
        return success
    }
}

public extension EthereumClient {
    var gasPrice: EthereumQuantity? {
        var _gasPrice: EthereumQuantity?
        
        let semaphore = DispatchSemaphore(value: 0)
        client.eth.gasPrice()
            .done(on: queue) { __gasPrice in
                _gasPrice = __gasPrice
            }.catch(on: queue) { _ in
                _gasPrice = nil
            }.finally(on: queue) {
                semaphore.signal()
            }; semaphore.wait()
        
        return _gasPrice
    }
    
    var nonce: EthereumQuantity? {
        var _nonce: EthereumQuantity?
        
        let semaphore = DispatchSemaphore(value: 0)
        client.eth.getTransactionCount(address: user!.address, block: .latest)
            .done(on: queue) { __nonce in
                _nonce = try! EthereumQuantity(__nonce.quantity)
            }.catch(on: queue) { _ in
                _nonce = nil
            }.finally(on: queue) {
                semaphore.signal()
            }; semaphore.wait()
        
        return _nonce
    }
}

public extension EthereumClient {
    func isTxSuccesful(txHash: EthereumData, interval: DispatchTimeInterval = .seconds(3)) -> Promise<Void> {
        return Promise { seal in
            var isTxPending = true
            let timer = DispatchSource.makeTimerSource(queue: queue)
            timer.schedule(deadline: .now(), repeating: interval)
            timer.setEventHandler {
                firstly {
                    self.client.eth.getTransactionReceipt(transactionHash: txHash)
                }.done(on: self.queue) { receipt in
                    if let status = receipt?.status {
                        isTxPending = false
                        if status == 1 {
                            seal.fulfill(())
                        } else {
                            seal.reject(EthereumClientError.txFailed)
                        }
                    }
                }.catch { error in
                    seal.reject(error)
                }
                
                if !isTxPending {
                    timer.cancel()
                }
            }
            timer.resume()
        }
    }
}

public extension EthereumClient {
    func getETC20NameAndSymbol(_ tokenContractAddress: EthereumAddress) throws -> (String, String) {
        let semaphore = DispatchSemaphore(value: 0)
        erc20.address = tokenContractAddress
        defer {
            erc20.address = nil
        }
        
        
        var err: Error?
        var name: String?, symbol: String?
        firstly {
            erc20.name().call()
        }.done(on: queue) { outputs in
            name = outputs["_name"] as? String
        }.catch(on: queue) { error in
            err = error
        }.finally(on: queue) {
            semaphore.signal()
        }; semaphore.wait()
        if err != nil {
            throw err!
        }
        
        firstly {
            erc20.symbol().call()
        }.done(on: queue) { outputs in
            symbol = outputs["_symbol"] as? String
        }.catch(on: queue) { error in
            err = error
        }.finally(on: queue) {
            semaphore.signal()
        }; semaphore.wait()
        if err != nil {
            throw err!
        }
        
        return (name ?? "Token", symbol ?? "SYM")
    }
    
    func
    createUTXO(from tokenContractAddress: EthereumAddress, amount: BigUInt) throws -> UTXO {
        let semaphore = DispatchSemaphore(value: 0)
        erc20.address = tokenContractAddress
        defer {
            erc20.address = nil
        }
        
        var err: Error?
        guard let approveTx = erc20.approve(spender: utxoStorage.address!, value: amount).createTransaction(
            nonce: nonce,
            gasPrice: EthereumQuantity(quantity: gasPrice!.quantity + 50.gwei),
            maxFeePerGas: EthereumQuantity(quantity: gasPrice!.quantity + 100.gwei),
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
            nonce: try? EthereumQuantity(nonce!.quantity + 1),
            gasPrice: EthereumQuantity(quantity: gasPrice!.quantity + 50.gwei),
            maxFeePerGas: EthereumQuantity(quantity: gasPrice!.quantity + 100.gwei),
            maxPriorityFeePerGas: EthereumQuantity(quantity: 3.gwei),
            gasLimit: 3000000,
            from: self.user!.address,
            value: 0,
            accessList: [:],
            transactionType: .legacy
        ) else {
            throw EthereumClientError.failedToCreateTx
        }
        
        
        firstly {
            try approveTx.sign(with: user!, chainId: 5).guarantee
        }.then(on: queue) { signedTx in
            return self.client.eth.sendRawTransaction(transaction: signedTx)
        }.then(on: queue) { txHash in
            self.logger.info("Approve Tx: \(txHash.hex())")
            return self.isTxSuccesful(txHash: txHash)
        }.then(on: queue) { _ in
            try depositTx.sign(with: self.user!, chainId: 5).guarantee
        }.then(on: queue) { signedTx in
            self.client.eth.sendRawTransaction(transaction: signedTx)
        }.then(on: queue) { txHash in
            self.logger.info("Deposit Tx: \(txHash.hex())")
            return self.isTxSuccesful(txHash: txHash)
        }.done(on: queue) { _ in
        }.catch(on: queue) { error in
            err = error
        }.finally(on: queue) {
            semaphore.signal()
        }; semaphore.wait()
        if err != nil {
            throw err!
        }

        var flag = true
        while flag {
            firstly {
                utxoStorage.listUTXOsByAddress(
                    owner: self.user!.address,
                    offset: BigUInt(userUTXOs.count),
                    limit: 5
                ).call()
            }.done(on: queue) { values in
                let utxos = UTXOStorageContract.UTXO.getUTXOsFromAny(values: values["UTXOs"]!)
                if utxos.isEmpty {
                    flag = false
                }
                
                self.userUTXOs.append(contentsOf: utxos)
            }.catch(on: queue) { error in
                err = error
            }.finally(on: queue) {
                semaphore.signal()
            }; semaphore.wait()
            if err != nil {
                throw err!
            }
        }
        
        var name: String, symbol: String
        (name, symbol) = try getETC20NameAndSymbol(tokenContractAddress)
        
        return UTXO(
            id: BigUInt(userUTXOs.count-1),
            token: tokenContractAddress,
            amount: amount,
            owner: user!.address,
            name: name,
            symbol: symbol,
            status: .created
        )
    }
}
