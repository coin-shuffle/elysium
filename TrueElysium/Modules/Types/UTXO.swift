//
//  UTXO.swift
//  Elysium
//
//  Created by Ivan Lele on 17.02.2023.
//

import Foundation
import BigInt
import Web3
import SwiftUI

public struct UTXO: Identifiable, Codable {
    public var id: BigUInt
    public let token: EthereumAddress
    public let amount: BigUInt
    public var owner: EthereumAddress
    public let name: String
    public let symbol: String
    public var status: Status
    
    public init(
        id: BigUInt,
        token: EthereumAddress,
        amount: BigUInt,
        owner: EthereumAddress,
        name: String,
        symbol: String,
        status: Status = .creating
    ) {
        self.id = id
        self.token = token
        self.amount = amount
        self.owner = owner
        self.name = name
        self.symbol = symbol
        self.status = status
    }
    
    public init(token: EthereumAddress, amount: BigUInt, name: String, symbol: String) {
        self.id = 0
        self.token = token
        self.amount = amount
        self.owner = try! EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: true)
        self.name = name
        self.symbol = symbol
        self.status = .creating
    }
    
    public mutating func update(utxo: UTXO) {
        self.id = utxo.id
        self.owner = utxo.owner
        self.status = utxo.status
    }
}

public extension UTXO {
    struct Data {
        var id: BigUInt
        var token: String
        var amount: String
        var owner: String
        var name: String
        var symbol: String
        
        init() {
            self.id = 0
            self.token = ""
            self.amount = ""
            self.owner = ""
            self.name = ""
            self.symbol = ""
        }
    }
}

public extension UTXO {
    static let sampleData =
        [
            UTXO(
                id: 0,
                token: try! EthereumAddress(hex: "0x5F0C6c62C7982dCbE7d091fD05Ef8f3857645DA6", eip55: true),
                amount: 13123,
                owner: try! EthereumAddress(hex: "0xC37EE126208Aba4d9F5fe361279Ca3d882427C39", eip55: true),
                name: "Tether",
                symbol: "USDT"
            ),
            UTXO(
                id: 1,
                token: try! EthereumAddress(hex: "0x8c6c8a448f871B2036111b6B8AB64E5B57473585", eip55: true),
                amount: 4231,
                owner: try! EthereumAddress(hex: "0x138eE9E566e5B1cf78D636893f2AD05c0336c9Ea", eip55: true),
                name: "UniSwap",
                symbol: "UNI"
            ),
            UTXO(
                id: 2,
                token: try! EthereumAddress(hex: "0xb421672F2DEa1cb5067c267C687572fE19d23C84", eip55: true),
                amount: 6455,
                owner: try! EthereumAddress(hex: "0x108065AeBA5A85aDc9fD4D3718293986c525D2e1", eip55: true),
                name: "Chainlink",
                symbol: "LINK"
            )
        ]
}

public extension UTXO {
    enum Status: CustomStringConvertible, Codable {
        case creating
        case failed
        case created
        case shuffling
        case shuffled
        
        public var description: String {
            switch self {
            case .creating: return "Creating"
            case .created: return "Created"
            case .failed: return "Failed"
            case .shuffling: return "Shuffling"
            case .shuffled: return "Shuffled"
            }
        }
        
        public var color: Color {
            switch self {
            case .created: return .blue
            case .shuffling: return .yellow
            case .shuffled: return .green
            case .creating: return .gray
            case .failed: return .red
            }
        }
        
        enum Key: CodingKey {
            case rawValue
        }
        
        enum CodingError: Error {
            case unknownValue
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Key.self)
            let rawValue = try container.decode(Int.self, forKey: .rawValue)
            switch rawValue {
            case 0:
                self = .creating
            case 1:
                self = .failed
            case 2:
                self = .created
            case 3:
                self = .shuffling
            case 4:
                self = .shuffled
            default:
                throw CodingError.unknownValue
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Key.self)
            switch self {
            case .creating:
                try container.encode(0, forKey: .rawValue)
            case .failed:
                try container.encode(1, forKey: .rawValue)
            case .created:
                try container.encode(2, forKey: .rawValue)
            case .shuffling:
                try container.encode(3, forKey: .rawValue)
            case .shuffled:
                try container.encode(4, forKey: .rawValue)
            }
        }
    }
}
