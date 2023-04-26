//
//  SwiftUIView.swift
//  Elysium
//
//  Created by Ivan Lele on 17.02.2023.
//

import SwiftUI
import Neumorphic
import Web3

struct UTXOsView: View {
    @ObservedObject var utxoStore: UTXOStore
    @ObservedObject var tokenStore: TokenStore
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    @State private var isPresentCreateUTXO = false
    @State private var isPresentChangePrivateKey = false
    @State private var isPresentFilterSelection = false
    @State private var isNewest = false
    @State private var data = UTXO.Data()
    @State private var privateKey: String = ""
    @State private var _error: LocalizedError?
    @State var tokenAmountRange: ClosedRange<Float> = 1...10000
    @State var tokenAmountBounds: ClosedRange<Int> = 1...10000
    @State var chosenPopularToken = ERC20Token.CUSTOM
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
                    )}.reversedIf(isNewest)) { $utxo in
                        NavigationLink(
                            destination: UTXODetailView(
                                utxo: $utxo,
                                hasUser: ethereumClient.user != nil && privateKey.isEmpty && ethereumClient.user!.publicKey.address == utxo.owner,
                                shuffleClient: shuffleClient,
                                ethereumClient: ethereumClient
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
                    .fontWeight(.bold)
                    .frame(width: 150)
            }
            .softButtonStyle(
                RoundedRectangle(cornerRadius: 20),
                mainColor: .white,
                textColor: .blue
            )
            .disabled(
                ethereumClient.user == nil && privateKey.isEmpty
            )
            
        }
        .sheet(isPresented: $isPresentCreateUTXO) {
            NavigationView {
                NewUTXOView(
                    data: $data,
                    chosenPopularToken: $chosenPopularToken
                )
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
                    filterer: filterer,
                    isNewest: $isNewest
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
        
        let rawTokenAddress = chosenPopularToken == .CUSTOM ? data.token : chosenPopularToken.contractAddress
        guard let tokenAddress = try? EthereumAddress(hex: data.token, eip55: true) else {
            _error = UTXOsViewError.invalidTokenAddress
            return
        }
        
        var amounts: [BigUInt] = []
        guard let amount = BigUInt(data.amount) else {
            _error = UTXOsViewError.invalidAmount
            return
        }
        
        if !data.mustSplit {
            amounts.append(amount)
        } else {
            amounts.append(
                contentsOf: amount.splitWithNominations(
                    nominations: [1_000_000, 100_000, 10_000, 5_000, 1_000, 500, 200, 100, 50, 20, 10, 5, 2, 1]
                )
            )
        }
        
        Task {
            guard try await ethereumClient.isContract(tokenAddress) else {
                throw UTXOsViewError.invalidTokenAddress
            }
            
            guard let token = try? await tokenStore.getToken(tokenAddress) else {
                throw UTXOsViewError.failedToGetTokenNameAndSymbol
            }
            
            for _amount in amounts {
                utxoStore.utxos.append(UTXO(
                    token: tokenAddress,
                    amount: _amount,
                    name: token.name,
                    symbol: token.symbol
                ))
            }
            
            isPresentCreateUTXO = false
            
            guard let finishedUTXOs = try? await ethereumClient.createUTXOs(
                tokenStore: tokenStore,
                from: tokenAddress,
                amounts: amounts
            ) else {
                for (index, _) in amounts.enumerated() {
                    let utxoIndex = utxoStore.utxos.count-(amounts.count-index)
                    
                    var _utxo = utxoStore.utxos[utxoIndex]
                    
                    _utxo.status = .failed
                    
                    utxoStore.utxos[utxoIndex] = _utxo
                }
                _error = UTXOsViewError.failedToCreateUTXO
                return
            }
            
            for (index, _) in amounts.enumerated() {
                let utxoIndex = utxoStore.utxos.count-(amounts.count-index)
                var _utxo = utxoStore.utxos[utxoIndex]
                
                _utxo.update(utxo: finishedUTXOs[index])
                utxoStore.utxos[utxoIndex] = _utxo
            }
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
