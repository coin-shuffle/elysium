//
//  UTXOStorageContract.swift
//  TrueElysium
//
//  Created by Ivan Lele on 22.02.2023.
//

import Web3
import Web3ContractABI

open class UTXOStorageContract: StaticContract {
    public var address: EthereumAddress?
    public let eth: Web3.Eth
    
    public var events: [Web3ContractABI.SolidityEvent] = []
    
    public required init(address: EthereumAddress?, eth: Web3.Eth) {
        self.address = address
        self.eth = eth
    }
}

public extension UTXOStorageContract {
    struct Output: ABIConvertible {
        let amount: BigUInt
        let owner: EthereumAddress
        
        public init(amount: BigUInt, owner: EthereumAddress) {
            self.amount = amount
            self.owner = owner
        }
         
        public init?(hexString: String) {
            guard let _decoded = try? ABI.decodeParameter(type: .tuple([.uint256, .address]), from: hexString) else {
                return nil
            }
            
            guard let decoded = _decoded as? [Any] else {
                return nil
            }
            
            guard let owner = decoded[1] as? EthereumAddress,
                  let amount = decoded.first as? BigUInt
            else {
                return nil
            }
            
            self.amount = amount
            self.owner = owner
        }
        
        public func abiEncode(dynamic: Bool) -> String? {
            return try? ABI.encodeParameter(.tuple(.uint(amount), .address(owner)))
        }
    }
    
    struct UTXO: ABIDecodable {
        let id: BigUInt
        let token: EthereumAddress
        let amount: BigUInt
        let owner: EthereumAddress
        let isSpent: Bool
        
        public init?(hexString: String) {
            guard let _decoded = try? ABI.decodeParameter(type: .tuple([.uint256, .address, .uint256, .address, .bool]), from: hexString) else {
                return nil
            }
            
            guard let decoded = _decoded as? [Any] else {
                return nil
            }
            
            guard let id = decoded.first as? BigUInt,
                  let token = decoded[1] as? EthereumAddress,
                  let amount = decoded[2] as? BigUInt,
                  let owner = decoded[3] as? EthereumAddress,
                  let isSpent = decoded[4] as? Bool
            else {
                return nil
            }
            
            self.id = id
            self.token = token
            self.amount = amount
            self.owner = owner
            self.isSpent = isSpent
        }
        
        public init(id: BigUInt, token: EthereumAddress, amount: BigUInt, owner: EthereumAddress, isSpent: Bool) {
            self.id = id
            self.token = token
            self.amount = amount
            self.owner = owner
            self.isSpent = isSpent
        }
        
        public static func getUTXOsFromAny(values: Any) -> [UTXO] {
            guard let _values = values as? [Any] else {
                return []
            }
            var result: [UTXO] = []
            for value in _values {
                guard let _value = value as? [Any] else {
                    return []
                }
                
                result.append(
                    UTXO(
                        id: (_value[0] as? BigUInt)!,
                        token: (_value[1] as? EthereumAddress)!,
                        amount: (_value[2] as? BigUInt)!,
                        owner: (_value[3] as? EthereumAddress)!,
                        isSpent: (_value[4] as? Bool)!
                    )
                )
            }
            
            return result
        }
    }
}

public extension UTXOStorageContract {
    func deposit(token: EthereumAddress, outputs: [Output]) -> SolidityInvocation {
        let inputs = [
            SolidityFunctionParameter(name: "token_", type: .address),
            SolidityFunctionParameter(name: "outputs_", type: .array(type: .tuple([.uint256, .address]), length: nil))
        ]
        let method = SolidityNonPayableFunction(name: "deposit", inputs: inputs, handler: self)
        
        return method.invoke(token, outputs)
    }
    
    func listUTXOsByAddress(owner: EthereumAddress, offset: BigUInt, limit: BigUInt) -> SolidityInvocation {
        let inputs = [
            SolidityFunctionParameter(name: "address_", type: .address),
            SolidityFunctionParameter(name: "offset_", type: .uint256),
            SolidityFunctionParameter(name: "limit_", type: .uint256)
        ]
        
        let outputs = [
            SolidityFunctionParameter(name: "UTXOs", type: .array(type: .tuple([.uint256, .address, .uint256, .address, .bool]), length: nil))
        ]
        let method = SolidityConstantFunction(name: "listUTXOsByAddress", inputs: inputs, outputs: outputs, handler: self)
        return method.invoke(owner, offset, limit)
    }
    
    func getUTXOsLength() -> SolidityInvocation {
        let outputs = [
            SolidityFunctionParameter(name: "length", type: .uint256)
        ]
        let method = SolidityConstantFunction(name: "getUTXOsLength", outputs: outputs, handler: self)
        return method.invoke()
    }
}
