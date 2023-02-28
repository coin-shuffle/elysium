//
//  Room.swift
//  TrueElysium
//
//  Created by Ivan Lele on 28.02.2023.
//

import Web3
import CryptoSwift

public typealias Output = Bytes
public typealias Outputs = [Output]

public struct Room {
    public let utxo: UTXO
    public let output: Output
    public var publicRSAKeys: [RSA] = []
    public var status: ShuffleStatus = .searchParticipants
    public let privateRSAKey: RSA
    public let privateEthereumKey: EthereumPrivateKey
    public var participantCount: UInt64 = 0
    
    public init(
        utxo: UTXO,
        privateRSAKey: RSA,
        privateEthereumKey: EthereumPrivateKey,
        output: Output
    ) {
        self.utxo = utxo
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
