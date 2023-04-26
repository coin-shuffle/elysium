//
//  NewUTXO.swift
//  Elysium
//
//  Created by Ivan Lele on 19.02.2023.
//

import SwiftUI
import Combine

struct NewUTXOView: View {
    @Binding var data: UTXO.Data
    @Binding var chosenPopularToken: ERC20Token
    let popularTokens = ERC20Token.allCases
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Token address:")) {
                    TextField("0x0000000000000000000000000000000000000000", text: $data.token)
                        .disabled(chosenPopularToken != .CUSTOM)
                    HStack {
                        Text("Popular tokens")
                        Spacer()
                        Picker("Popular tokens", selection: $chosenPopularToken) {
                            ForEach(popularTokens, id: \.self) {
                                Text($0.description)
                            }
                        }
                        .labelsHidden()
                    }
                }
                Section(header: Text("Amount:")) {
                    TextField("0", text: $data.amount)
                        .keyboardType(.numberPad)
                    Toggle("Split up", isOn: $data.mustSplit)
                }
            }
        }
    }
}

struct NewUTXO_Previews: PreviewProvider {
    static var previews: some View {
        NewUTXOView(
            data: .constant(UTXO.Data()),
            chosenPopularToken: .constant(ERC20Token.CUSTOM)
        )
    }
}
