//
//  Client.swift
//  TrueElysium
//
//  Created by Ivan Lele on 27.02.2023.
//

//import GRPC
import SwiftUI
import SwiftyRSA
import Web3
import BigInt

enum NodeError: Error {
    case UTXODoesNotExists
    case RoomDoesNotExists
    case IncorrectOutputsSize
    case JWTDoesNotExists
}

public class Node {
    public var rooms: [Room]
    @ObservedObject var utxoStore: UTXOStore
    
    init(utxoStore: UTXOStore, rooms: [Room] = []) {
        self.utxoStore = utxoStore
        self.rooms = rooms
    }
    
    func addRoom(
        utxoID: BigUInt,
        output: Data,
        privateRSAKey: PrivateKey,
        privateEthereumKey: EthereumPrivateKey
    ) throws {
        guard let utxoIndex = utxoStore.utxos.firstIndex(where: {$0.ID == utxoID}) else {
            throw NodeError.UTXODoesNotExists
        }
        
        rooms.append(Room(
            utxoID: utxoID,
            amount: utxoStore.utxos[utxoIndex].amount,
            privateRSAKey: privateRSAKey,
            privateEthereumKey: privateEthereumKey,
            output: output
        ))
    }
    
    func updateShuffleInfo(
        utxoID: BigUInt,
        publicRSAKeys: [PublicKey]
    ) throws {
        guard let roomIndex = rooms.firstIndex(where: {$0.utxoID == utxoID}) else {
            throw NodeError.RoomDoesNotExists
        }
        
        rooms[roomIndex].publicRSAKeys = publicRSAKeys
    }
    
    func shuffleRound(
        utxoID:  BigUInt,
        encryptedOutputs: [Data]
    ) throws -> [Data] {
        guard let roomIndex = rooms.firstIndex(where: {$0.utxoID == utxoID}) else {
            throw NodeError.RoomDoesNotExists
        }
        
        rooms[roomIndex].participantCount = UInt64(encryptedOutputs.count + rooms[roomIndex].publicRSAKeys.count + 1)
            
        var result: [Data] = []
        
        for encryptedOutput in encryptedOutputs {
            result.append(
                Data(try rsaDecrypt(msg: encryptedOutput.bytes, privateKey: rooms[roomIndex].privateRSAKey))
            )
        }
        
        let nonce = Nonce()
        var encryptedOutput = rooms[roomIndex].output
        for publicKey in rooms[roomIndex].publicRSAKeys {
            encryptedOutput = Data(try rsaEncrypt(msg: encryptedOutput.bytes, publicKey: publicKey, nonce: nonce))
        }
        
        result.append(encryptedOutput)
        
        return result
    }
    
    func signTx(
        utxoID: BigUInt,
        outputs: [Data]
    ) throws -> [UInt8]{
        guard let roomIndex = rooms.firstIndex(where: {$0.utxoID == utxoID}) else {
            throw NodeError.RoomDoesNotExists
        }
        
        if rooms[roomIndex].participantCount != outputs.count {
            throw NodeError.IncorrectOutputsSize
        }
        
        var signMsg = rooms[roomIndex].utxoID.hexEncode
        for output in outputs {
            signMsg.append(contentsOf: rooms[roomIndex].amount.hexEncode)
            signMsg.append(contentsOf: output)
        }
        
        return try ecdsaTXSign(msg: signMsg, privateKey: rooms[roomIndex].privateEthereumKey)
    }
}

extension Node {
    func getRoomIndex(utxoID: BigUInt) throws -> Int {
        guard let roomIndex = rooms.firstIndex(where: {$0.utxoID == utxoID}) else {
            throw NodeError.RoomDoesNotExists
        }
        
        return roomIndex
    }
    
    func setJwt(utxoID: BigUInt, jwt: String) throws {
        rooms[try getRoomIndex(utxoID: utxoID)].jwt = jwt
    }
    
    func getJwt(utxoID: BigUInt) throws -> String{
        guard let jwt = rooms[try getRoomIndex(utxoID: utxoID)].jwt else {
            throw NodeError.JWTDoesNotExists
        }
        
        return jwt
    }
    
    func getPublicRsaKey(utxoID: BigUInt) throws -> PublicKey {
        return rooms[try getRoomIndex(utxoID: utxoID)].privateRSAKey.publicKey
    }
}

extension Node {
    func updateUTXOStatus(utxoID: BigUInt, status: UTXO.Status) throws {
        guard let utxoIndex = utxoStore.utxos.firstIndex(where: {$0.ID == utxoID}) else {
            throw NodeError.UTXODoesNotExists
        }
        
        DispatchQueue.main.async {
            self.utxoStore.utxos[utxoIndex].status = status
        }
    }
}
