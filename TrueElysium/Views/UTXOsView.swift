//
//  SwiftUIView.swift
//  Elysium
//
//  Created by Ivan Lele on 17.02.2023.
//

import SwiftUI
import Web3

struct UTXOsView: View {
    @ObservedObject var utxoStore: UTXOStore
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    @State private var isPresentCreateUTXO = false
    @State private var isPresentChangePrivateKey = false
    @State private var data = UTXO.Data()
    @State private var privateKey: String = ""
    @State private var _error: LocalizedError?
    var ethereumClient: EthereumClient
    var shuffleClient: ShuffleClient
    let saveAction: ()->Void
    
    var body: some View {
        VStack {
            HeaderView(
                isPresentChangePrivateKey: $isPresentChangePrivateKey)
            if !utxoStore.utxos.isEmpty {
                List {
                    ForEach($utxoStore.utxos) {$utxo in
                        NavigationLink(
                            destination: UTXODetailView(
                                utxo: $utxo,
                                hasUser: ethereumClient.user != nil && privateKey.isEmpty,
                                shuffleClient: shuffleClient,
                                ethreumClient: ethereumClient
                            )
                        ) {
                            CardUTXOView(utxo: utxo)
                        }
                    }
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .inactive {
                        saveAction()
                    }
                }
            } else {
                Spacer()
                Label("You do not have UTXO yet", systemImage: "nosign")
                Spacer()
            }
            Button(action: {
                isPresentCreateUTXO = true
            }) {
                Text("New")
                    .font(.bold(.headline)())
            }
            .disabled(ethereumClient.user == nil && privateKey.isEmpty)
            
        }
        .sheet(isPresented: $isPresentCreateUTXO) {
            NavigationView {
                NewUTXOView(data: $data)
                    .navigationTitle("New")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentCreateUTXO = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                createUTXO()
                            }
                        }
                    }
                    .errorAlert(error: $_error, actor: $isPresentCreateUTXO)
            }
        }
        .sheet(isPresented: $isPresentChangePrivateKey) {
            NavigationView {
                ChangePrivateKeyView(privateKey: $privateKey)
                    .navigationTitle("Private key")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentChangePrivateKey = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                savePrivateKey()
                            }
                        }
                    }
                    .errorAlert(error: $_error, actor: $isPresentChangePrivateKey)
            }
        }
        .task {
            try? await Task.sleep(for: Duration.seconds(2))
            self.launchScreenState.dismiss()
        }
    }
    
    func savePrivateKey() {
        defer {
            privateKey = ""
        }
        
        guard let _privateKey = try? EthereumPrivateKey(hexPrivateKey: privateKey) else {
            _error = UTXOsViewError.invalidPrivateKey
            return
        }
        
        ethereumClient.user = _privateKey
        
        isPresentChangePrivateKey = false
    }
    
    func createUTXO() {
        defer {
            data.token = ""
            data.amount = ""
        }
        
        guard let tokenAddress = try? EthereumAddress(hex: data.token, eip55: true) else {
            _error = UTXOsViewError.invalidTokenAddress
            return
        }
        
        guard let amount = BigUInt(data.amount) else {
            _error = UTXOsViewError.invalidAmount
            return
        }
        
        Task {
            if !(try await ethereumClient.isContract(tokenAddress)) {
                _error = UTXOsViewError.invalidTokenAddress
                return
            }
            
            guard let (name, symbol) = try? await ethereumClient.getETC20NameAndSymbol(tokenAddress) else {
                _error = UTXOsViewError.failedToGetTokenNameAndSymbol
                return
            }
            
            utxoStore.utxos.append(UTXO(
                token: tokenAddress,
                amount: amount,
                name: name,
                symbol: symbol
            ))
            
            let utxoIndex = utxoStore.utxos.endIndex-1
            
            isPresentCreateUTXO = false
            
            guard let finishedUTXO = try? await ethereumClient.createUTXO(from: tokenAddress, amount: amount)
            else {
                var _utxo = utxoStore.utxos[utxoIndex]
                
                _utxo.status = .failed
                
                utxoStore.utxos[utxoIndex] = _utxo
                _error = UTXOsViewError.failedToCreateUTXO
                return
            }
            
            var _utxo = utxoStore.utxos[utxoIndex]
            
            _utxo.update(utxo: finishedUTXO)
            
            utxoStore.utxos[utxoIndex] = _utxo
        }
    }
}



struct UTXOsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UTXOsView(
                utxoStore: UTXOStore(),
                ethereumClient: try! EthereumClient(
                utxoStorageContractAddress: try! EthereumAddress(hex: "0x4C0d116d9d028E60904DCA468b9Fa7537Ef8Cd5f", eip55: true)
                ),
                shuffleClient: try! ShuffleClient(
                    grpcHost: "3.23.147.9",
                    port: 8080,
                    node: Node(
                        utxoStore: UTXOStore()
                    )
                )
            ) {}
            .environmentObject(LaunchScreenStateManager())
        }
    }
}