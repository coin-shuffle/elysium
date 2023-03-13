//
//  UTXODetailView.swift
//  Elysium
//
//  Created by Ivan Lele on 20.02.2023.
//

import SwiftUI
import Web3
import Neumorphic
import UniformTypeIdentifiers

struct UTXODetailView: View {
    @Binding var utxo: UTXO
    let hasUser: Bool
    let shuffleClient: ShuffleClient
    let ethreumClient: EthereumClient
    
    @State private var output: String = ""
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("UTXO INFO").font(.headline)) {
                    HStack {
                        Text("ID")
                        Spacer()
                        Text(utxo.ID.description)
                    }
                    HStack {
                        Text("Token address")
                        Spacer()
                        Text(utxo.token.hex(eip55: true).contraction(maxLength: 10))
                            .multilineTextAlignment(.trailing)
                            .onTapGesture(count: 2) {
                                UIPasteboard.general.setValue(
                                    utxo.token.hex(eip55: true),
                                    forPasteboardType: UTType.plainText.identifier
                                )
                            }
                    }
                    HStack {
                        Text("Amount")
                        Spacer()
                        Text(utxo.amount.description)
                    }
                    HStack {
                        Text("Owner")
                        Spacer()
                        Text(utxo.owner.hex(eip55: true).contraction(maxLength: 10))
                            .multilineTextAlignment(.trailing)
                            .onTapGesture(count: 2) {
                                UIPasteboard.general.setValue(
                                    utxo.owner.hex(eip55: true),
                                    forPasteboardType: UTType.plainText.identifier
                                )
                            }
                    }
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(utxo.status.description)
                            .foregroundColor(utxo.status.color)
                    }
                }
            }
            if hasUser && utxo.status == .created {
                HStack {
                    TextField("0x00...00", text: $output)
                    Button(action: shuffleAction) {
                        Text("Shuffle")
                    }
                    .softButtonStyle(
                        RoundedRectangle(cornerRadius: 20),
                        mainColor: .white,
                        textColor: .blue
                    )
                    .buttonStyle(.borderedProminent)
                    .disabled(output.isEmpty)
                }
                .disabled(!hasUser || utxo.status != .created)
                .padding()
            }
        }
        .navigationTitle("\(utxo.name)(\(utxo.symbol))")
    }
    
    func shuffleAction() {
        guard let outputAddress = try? EthereumAddress(
            hex: output,
            eip55: true
        ) else {
            output = ""
            return
        }
        
        Task {
            do {
                try await shuffle(
                    outputAddress:outputAddress
                )
            } catch {
                try! await shuffleClient.node.updateUTXOStatus(
                    utxoID: utxo.ID,
                    status: .created
                )
                
                shuffleClient.logger.error(
                    "UTXO ID: \(utxo.ID), received an error: \(error)"
                )
            }
        }
        
        output = ""
    }
    
    func shuffle(outputAddress: EthereumAddress) async throws  {
        try await shuffleClient.initRoom(
            utxoID: utxo.ID,
            outputAddress: outputAddress,
            privateEthKey: ethreumClient.user!
        )
        try await shuffleClient.joinRoom(utxoID: utxo.ID)
        try await shuffleClient.waitShuffle(utxoID: utxo.ID)
        try await shuffleClient.connectRoom(utxoID: utxo.ID)
    }
}

struct UTXODetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UTXODetailView(
                utxo: .constant(UTXO.sampleData[0]),
                hasUser: true,
                shuffleClient: try! ShuffleClient(
                    cfg: parseConfig().CoinShuffleSvcConfig,
                    node: Node(
                        utxoStore: UTXOStore()
                    )
                ),
                ethreumClient: try! EthereumClient(
                    netCfg: parseConfig().NetConfig
                )
            )
        }
    }
}
