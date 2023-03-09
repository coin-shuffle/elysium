//
//  ElysiumApp.swift
//  Elysium
//
//  Created by Ivan Lele on 09.02.2023.
//

import SwiftUI
import Web3

let cfg = parseConfig()

let _ethereumClient = try! EthereumClient(
    netCfg: cfg.NetConfig
)

@main
struct ElysiumApp: App {
    @StateObject private var store = UTXOStore()
    @StateObject private var tokenStore = TokenStore(
        ethereumClient: _ethereumClient
    )
    @StateObject var launchScreenState = LaunchScreenStateManager()
    let ethereumClient = _ethereumClient
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack {
                    UTXOsView(
                        utxoStore: store,
                        tokenStore: tokenStore,
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
                        
                        TokenStore.save(tokens: tokenStore.tokens) { result in
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
                    
                    TokenStore.load {result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let tokens):
                            tokenStore.tokens = tokens
                        }
                    }
                    
                    Task {
                        await UTXOLoader(
                            utxoStore: store,
                            tokenStore: tokenStore,
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

