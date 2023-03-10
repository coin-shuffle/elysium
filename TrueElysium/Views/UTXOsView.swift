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
    @ObservedObject var tokenStore: TokenStore
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    @State private var isPresentCreateUTXO = false
    @State private var isPresentChangePrivateKey = false
    @State private var isPresentFilterSelection = false
    @State private var data = UTXO.Data()
    @State private var privateKey: String = ""
    @State private var _error: LocalizedError?
    @State var tokenAmountRange: ClosedRange<Float> = 1...10000
    @State var tokenAmountBounds: ClosedRange<Int> = 1...10000
    @StateObject private var filterer = Filterer()
    var ethereumClient: EthereumClient
    var shuffleClient: ShuffleClient
    let saveAction: ()->Void
    
    var body: some View {
        VStack {
            HeaderView(
                isPresentChangePrivateKey: $isPresentChangePrivateKey,
                isPresentFilterSelection: $isPresentFilterSelection
            )
            if !utxoStore.utxos.isEmpty {
                List {
                    ForEach($utxoStore.utxos.filter {filterer.filter(
                        utxo: $0.wrappedValue,
                        user: ethereumClient.user?.publicKey.address
                    )}) { $utxo in
                        NavigationLink(
                            destination: UTXODetailView(
                                utxo: $utxo,
                                hasUser: ethereumClient.user != nil && privateKey.isEmpty && ethereumClient.user!.publicKey.address == utxo.owner,
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
            .disabled(
                ethereumClient.user == nil && privateKey.isEmpty
            )
            
        }
        .sheet(isPresented: $isPresentCreateUTXO) {
            NavigationView {
                NewUTXOView(data: $data)
                    .navigationTitle("New")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                privateKey = ""
                                isPresentCreateUTXO = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                createUTXO()
                            }
                        }
                    }
                    .errorAlert(
                        error: $_error,
                        actor: $isPresentCreateUTXO
                    )
            }
        }
        .sheet(isPresented: $isPresentFilterSelection) {
            NavigationView {
                FilterView(
                    filterer: filterer
                )
                    .navigationTitle("Filtering")
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
                    .errorAlert(
                        error: $_error,
                        actor: $isPresentChangePrivateKey
                    )
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
            guard try await ethereumClient.isContract(tokenAddress) else {
                throw UTXOsViewError.invalidTokenAddress
            }
            
            guard let token = try? await tokenStore.getToken(tokenAddress) else {
                throw UTXOsViewError.failedToGetTokenNameAndSymbol
            }
            
            utxoStore.utxos.append(UTXO(
                token: tokenAddress,
                amount: amount,
                name: token.name,
                symbol: token.symbol
            ))
            
            let utxoIndex = utxoStore.utxos.endIndex-1
            
            isPresentCreateUTXO = false
            
            guard let finishedUTXO = try? await ethereumClient.createUTXO(
                tokenStore: tokenStore,
                from: tokenAddress,
                amount: amount
            ) else {
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
                tokenStore: TokenStore(
                    ethereumClient: try! EthereumClient(
                        netCfg: parseConfig().NetConfig
                    )
                ),
                ethereumClient: try! EthereumClient(
                    netCfg: parseConfig().NetConfig
                ),
                shuffleClient: try! ShuffleClient(
                    cfg: parseConfig().CoinShuffleSvcConfig,
                    node: Node(
                        utxoStore: UTXOStore()
                    )
                )
            ) {}
            .environmentObject(LaunchScreenStateManager())
        }
    }
}
