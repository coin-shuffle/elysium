import Foundation
import GRPC
import Web3
import NIO
import NIOCore
import NIO
import NIOHPACK
import SwiftyRSA
import Logging
import Collections

class ShuffleClient {
    let rawClient: CoinShuffle_V1_ShuffleServiceAsyncClient
    let node: Node
    let logger = Logger(label: "info")
    
    init(grpcHost: String, port: Int, node: Node) throws {
        self.node = node
        
        let channel = try GRPCChannelPool.with(
            target: .host(grpcHost, port: port),
            transportSecurity: .plaintext,
            eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1)
        )
        
        self.rawClient = CoinShuffle_V1_ShuffleServiceAsyncClient(channel: channel)
    }
    
    func initRoom(
        utxoID: BigUInt,
        outputAddress: EthereumAddress,
        privateEthKey: EthereumPrivateKey
    ) async throws {
        let privateRSAKey = try newRandomRSAPrivateKey(keyLength: 2048)
        
        try await node.addRoom(
            utxoID: utxoID,
            output: Data(try outputAddress.makeBytes()),
            privateRSAKey: privateRSAKey,
            privateEthereumKey: privateEthKey
        )
        
        try await self.node.updateUTXOStatus(utxoID: utxoID, status: .searching)
    }
    
    func joinRoom(utxoID: BigUInt) async throws {
        let roomIndex = try await node.getRoomIndex(utxoID: utxoID)
        
        let timestamp = UInt64(NSDate().timeIntervalSince1970)
        
        let prefix = Array(repeating: UInt8(0), count: 32-utxoID.makeBytes().count)
        
        let signature = try await ecdsaSign(
            msg: prefix + utxoID.makeBytes() + timestamp.makeBytes(),
            privateKey: node.rooms[roomIndex].privateEthereumKey
        )
        
        let _utxoID = try Data(utxoID)
        
        let resp = try await rawClient.joinShuffleRoom(
            CoinShuffle_V1_JoinShuffleRoomRequest.with {
                $0.utxoID = Array(repeating: UInt8(0), count: 32-_utxoID.count) + _utxoID
                $0.timestamp = timestamp
                $0.signature = Data(signature)
            }
        )
        
        try await node.setJwt(utxoID: utxoID, jwt: resp.roomAccessToken)
        
        logger.info("UTXO ID: \(utxoID). Succesfully joined a queue")
    }
    
    func waitShuffle(utxoID: BigUInt) async throws {
        var isReady = false
        
        while !isReady {
            try await Task.sleep(nanoseconds: UInt64(30 * Double(NSEC_PER_SEC)))
            let resp = try await rawClient.isReadyForShuffle(
                CoinShuffle_V1_IsReadyForShuffleRequest(),
                callOptions: try auth(utxoID: utxoID)
            )
            
            isReady = resp.ready
            try await node.setJwt(utxoID: utxoID, jwt: resp.roomAccessToken)
            logger.info("UTXO ID: \(utxoID). Checking a queue status..., isReady: \(isReady)")
        }
    }
    
    func connectRoom(utxoID: BigUInt) async throws {
        var protoPubKey = CoinShuffle_V1_RsaPublicKey()
        (protoPubKey.modulus, protoPubKey.exponent)
            = try await node.getPublicRsaKey(utxoID: utxoID).getModulusAndExponent()
        
        try await self.node.updateUTXOStatus(utxoID: utxoID, status: .shuffling)
        
        for try await event in rawClient.connectShuffleRoom(
            CoinShuffle_V1_ConnectShuffleRoomRequest.with {
                $0.publicKey = protoPubKey
            },
            callOptions: try auth(utxoID: utxoID)
        ) {
            try await shuffling(utxoID: utxoID, event: event)
        }
    }
}

extension ShuffleClient {
    func shuffling(utxoID: BigUInt, event: CoinShuffle_V1_ShuffleEvent) async throws {
        guard let body = event.body else {
            return
        }
        
        switch body {
        case .shuffleInfo(let eventBody):
            try await shuffleInfoEvent(utxoID: utxoID, eventBody: eventBody)
        case .encodedOutputs(let eventBody):
            try await encryptedOutputsEvent(utxoID: utxoID, eventBody: eventBody)
        case .txSigningOutputs(let eventBody):
            try await signOutputsEvent(utxoID: utxoID, eventBody: eventBody)
        case .shuffleTxHash(let eventBody):
            try txHashEvent(utxoID: utxoID, eventBody: eventBody)
        case .error(let eventBody):
            try errorEvent(utxoID: utxoID, eventBody: eventBody)
        }
    }
    
    func shuffleInfoEvent(utxoID: BigUInt, eventBody: CoinShuffle_V1_ShuffleInfo) async throws {
        logger.info("UTXO ID: \(utxoID), received a shuffle info event")
        var publicKeys: [PublicKey] = []
        for publicRawKey in eventBody.publicKeysList {
            let publicKey = try PublicKey(
                modulus: publicRawKey.modulus,
                exponent: publicRawKey.exponent
            )
            
            publicKeys.append(publicKey)
        }
        
        try await node.updateShuffleInfo(
            utxoID: utxoID,
            publicRSAKeys: publicKeys
        )
        
        try await node.setJwt(utxoID: utxoID, jwt: eventBody.shuffleAccessToken)
    }
    
    func encryptedOutputsEvent(utxoID: BigUInt, eventBody: CoinShuffle_V1_EncodedOutputs) async throws {
        logger.info("UTXO ID: \(utxoID), received a encrypt outputs event")
        
        let decryptedOutputs = try await node.shuffleRound(
            utxoID: utxoID,
            encryptedOutputs: eventBody.outputs
        )
        
        let callOpt = try auth(utxoID: utxoID)
        
        _ = try await rawClient.shuffleRound(
            CoinShuffle_V1_ShuffleRoundRequest.with {
                $0.encodedOutputs = decryptedOutputs
            },
            callOptions: callOpt
        )
    }
    
    func signOutputsEvent(utxoID: BigUInt, eventBody: CoinShuffle_V1_TxSigningOutputs) async throws  {
        logger.info("UTXO ID: \(utxoID), received a sign outputs event")
        
        print()
        
        let signature = try await node.signTx(
            utxoID: utxoID,
            outputs: eventBody.outputs
        )
        
        let callOpt = try auth(utxoID: utxoID)
        
        let _ = try? await rawClient.signShuffleTx(
            CoinShuffle_V1_SignShuffleTxRequest.with {
                $0.signature = Data(signature)
            },
            callOptions: callOpt
        )
    }
    
    func txHashEvent(utxoID: BigUInt, eventBody: CoinShuffle_V1_ShuffleTxHash) throws {
        try self.node.updateUTXOStatus(utxoID: utxoID, status: .shuffled)
        logger.info("UTXO ID: \(utxoID), received a shuffling tx hash: \(eventBody.txHash.toHexString())")
    }
    
    func errorEvent(utxoID: BigUInt, eventBody: CoinShuffle_V1_ShuffleError) throws {
        try self.node.updateUTXOStatus(utxoID: utxoID, status: .failed)
        logger.error("UTXO ID: \(utxoID), received an error: \(eventBody.error)")
    }
}

extension ShuffleClient {
    internal func auth(utxoID: BigUInt) throws -> CallOptions {
        let jwt = try node.getJwt(utxoID: utxoID)
        
        return CallOptions(
            customMetadata: HPACKHeaders(
                httpHeaders: ["authorization": "Bearer \(jwt)"]
            )
        )
    }
}
