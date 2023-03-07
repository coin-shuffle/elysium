//
//  Room.swift
//  TrueElysium
//
//  Created by Ivan Lele on 28.02.2023.
//

import Foundation
import Web3
import SwiftyRSA
import CryptoSwift

public typealias Output = Bytes
public typealias Outputs = [Output]

public struct Room {
    public let utxoID: BigUInt
    public let amount: BigUInt
    public let output: Data
    public var publicRSAKeys: [PublicKey] = []
    public var status: ShuffleStatus = .searchParticipants
    public let privateRSAKey: PrivateKey
    public let privateEthereumKey: EthereumPrivateKey
    public var participantCount: UInt64 = 0
    public var jwt: String?
    
    public init(
        utxoID: BigUInt,
        amount: BigUInt,
        privateRSAKey: PrivateKey,
        privateEthereumKey: EthereumPrivateKey,
        output: Data
    ) {
        self.utxoID = utxoID
        self.amount = amount
        self.privateRSAKey = privateRSAKey
        self.privateEthereumKey = privateEthereumKey
        self.output = output
    }
}

public extension Room {
    enum ShuffleStatus {
        case searchParticipants
        case shuffleStart
        case shuffle
        case signingOutputs
        case txHashDistribution
    }
}
