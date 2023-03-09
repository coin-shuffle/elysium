//
//  UTXOSLoader.swift
//  TrueElysium
//
//  Created by Ivan Lele on 09.03.2023.
//

import Foundation
import BigInt
import SwiftUI

class UTXOLoader {
    @ObservedObject var utxoStore: UTXOStore
    let ethereumClient: EthereumClient
    var offset: BigUInt = 0
    
    init(utxoStore: UTXOStore, ethereumClient: EthereumClient) {
        self.utxoStore = utxoStore
        self.ethereumClient = ethereumClient
    }
    
    func fetch() async throws {
        while true {
            try await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC)
            
            if ethereumClient.user == nil {
                continue
            }
            
            let utxosLength = try await ethereumClient.getUTXOsLength()
            if offset > utxosLength {
                continue
            }
            
            let utxos = try await ethereumClient.listUTXOsByAddress(
                owner: ethereumClient.user!.address,
                offset: offset,
                limit: 100
            )
            
            offset += 100
            
            for utxo in utxos {
                let (name, symbol) = try await ethereumClient.getETC20NameAndSymbol(utxo.token)
                
                let _utxo = UTXO(
                    ID: utxo.id,
                    token: utxo.token,
                    amount: utxo.amount,
                    owner: utxo.owner,
                    name: name,
                    symbol: symbol,
                    status: (utxo.isSpent) ? .shuffled : .created
                )
                
                utxoStore.utxos.append(_utxo)
            }
        }
    }
    
    func recover(_ f: () async throws -> Void) async {
        while true {
            do {
                try await f()
            } catch {
                print("UTXO Loader Error: \(error)")
            }
        }
    }
    
    func run() async  {
        await recover(fetch)
    }
}
