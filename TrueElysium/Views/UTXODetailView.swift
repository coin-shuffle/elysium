//
//  UTXODetailView.swift
//  Elysium
//
//  Created by Ivan Lele on 20.02.2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct UTXODetailView: View {
    @Binding var utxo: UTXO
    let hasUser: Bool
    var body: some View {
        VStack {
            List {
                Section(header: Text("UTXO INFO")) {
                    HStack {
                        Text("ID")
                        Spacer()
                        Text(utxo.id.description)
                    }
                    HStack {
                        Text("Token address")
                        Spacer()
                        Text(utxo.token.hex(eip55: true).contraction(maxLength: 10))
                            .multilineTextAlignment(.trailing)
                            .onTapGesture(count: 2) {
                                UIPasteboard.general.setValue(utxo.token.hex(eip55: true),
                                        forPasteboardType: UTType.plainText.identifier)
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
                                UIPasteboard.general.setValue(utxo.owner.hex(eip55: true),
                                        forPasteboardType: UTType.plainText.identifier)
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
            Button("Shuffle") {
                utxo.status = .shuffling
            }
            .disabled(!hasUser && utxo.status != .created)
        }
        .navigationTitle("\(utxo.name)(\(utxo.symbol))")
    }
}

struct UTXODetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UTXODetailView(utxo: .constant(UTXO.sampleData[0]), hasUser: true)
        }
    }
}
