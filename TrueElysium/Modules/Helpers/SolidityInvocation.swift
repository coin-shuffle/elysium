//
//  SolidityInvocation.swift
//  TrueElysium
//
//  Created by Ivan Lele on 26.02.2023.
//

import Web3
import Collections
import Web3ContractABI

public extension SolidityInvocation {
    func createTx(
        nonce: EthereumQuantity? = nil,
        gasPrice: EthereumQuantity? = nil,
        maxFeePerGas: EthereumQuantity? = nil,
        maxPriorityFeePerGas: EthereumQuantity? = nil,
        gasLimit: EthereumQuantity? = nil,
        from: EthereumAddress? = nil,
        value: EthereumQuantity? = nil,
        accessList: OrderedDictionary<EthereumAddress, [EthereumData]> = [:],
        transactionType: EthereumTransaction.TransactionType = .legacy
    ) -> EthereumTransaction? {
        guard let hexString = try? ABI.encodeFunctionCall(self) else {
            return nil
        }
        guard let data = try? EthereumData(ethereumValue: hexString.removeSubstringExceptFirst("0x")) else {
            return nil
        }
        
        guard let to = handler.address else { return nil }
        
        return EthereumTransaction(
            nonce: nonce,
            gasPrice: gasPrice,
            maxFeePerGas: maxFeePerGas,
            maxPriorityFeePerGas: maxPriorityFeePerGas,
            gasLimit: gasLimit,
            from: from,
            to: to,
            value: value,
            data: data,
            accessList: accessList,
            transactionType: transactionType
        )
    }
}

