//
//  ElysiumApp.swift
//  Elysium
//
//  Created by Ivan Lele on 09.02.2023.
//

import SwiftUI
import Web3

let cfg = parseConfig()

@main
struct ElysiumApp: App {
    @StateObject private var store = UTXOStore()
    @StateObject var launchScreenState = LaunchScreenStateManager()
    let ethereumClient = try! EthereumClient(
        netCfg: cfg.NetConfig
    )
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack {
                    UTXOsView(
                        utxoStore: store,
                        ethereumClient: ethereumClient,
                        shuffleClient:  try! ShuffleClient(
                            cfg: cfg.CoinShuffleSvcConfig,
                            node: Node(
                                utxoStore: store
                            )
                        )
                    ) {
                        UTXOStore.save(utxos: store.utxos) { result in
                            if case .failure(let error) = result {
                                fatalError(error.localizedDescription)
                            }
                        }
                    }
                }
                .onAppear {
                    UTXOStore.load {result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let utxos):
                            store.utxos = utxos
                        }
                    }
                    Task {
                        await UTXOLoader(
                            utxoStore: store,
                            ethereumClient: ethereumClient
                        ).run()
                    }
                }
                
                if launchScreenState.state {
                    MainLoaderView()
                }
                
            }
            .environmentObject(launchScreenState)
        }
    }
}

