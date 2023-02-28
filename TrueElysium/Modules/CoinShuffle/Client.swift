//
//  Client.swift
//  TrueElysium
//
//  Created by Ivan Lele on 27.02.2023.
//

//import GRPC
import CryptoSwift
import BigInt

enum NodeError: Error {
    case roomWasNotSet
}

public class Node {
    var room: Room?
    var utxoStore: UTXOStore
    
    init(utxoStore: UTXOStore, room: Room? = nil) {
        self.utxoStore = utxoStore
        self.room = room
    }
}

public extension Node {
    func updateShuffleInfo(publicRSAKeys: [RSA]) throws {
        if room == nil {
            throw NodeError.roomWasNotSet
        }
                
        room!.publicRSAKeys = publicRSAKeys
    }
    
    func shuffleRound(encodedOutputs: Outputs) throws {
        if room == nil {
            throw NodeError.roomWasNotSet
        }
                
        room?.participantCount = UInt64(encodedOutputs.count + room!.publicRSAKeys.count + 1)
        
//        for encodedOutput in encodedOutputs {
//            let encodingResult =
//        }
    }
}
