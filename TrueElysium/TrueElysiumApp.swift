//
//  ElysiumApp.swift
//  Elysium
//
//  Created by Ivan Lele on 09.02.2023.
//

import SwiftUI
import Web3

@main
struct ElysiumApp: App {
    @StateObject private var store = UTXOStore()
    @StateObject var launchScreenState = LaunchScreenStateManager()
    let ethereumClient = try! EthereumClient(
        utxoStorageContractAddress: try! EthereumAddress(hex: "0x4C0d116d9d028E60904DCA468b9Fa7537Ef8Cd5f", eip55: true)
    )
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack {
                    UTXOsView(utxoStore: store, ethereumClient: ethereumClient) {
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
                }
                
                if launchScreenState.state {
                    MainLoaderView()
                }
                
            }
            .environmentObject(launchScreenState)
        }
    }
}

