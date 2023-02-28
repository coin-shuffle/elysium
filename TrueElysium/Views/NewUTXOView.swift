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
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Token address:")) {
                    TextField("0x0000000000000000000000000000000000000000", text: $data.token)
                }
                Section(header: Text("Amount:")) {
                    TextField("0", text: $data.amount)
                        .keyboardType(.numberPad)
                    
                }
            }
        }
    }
}

struct NewUTXO_Previews: PreviewProvider {
    static var previews: some View {
        NewUTXOView(data: .constant(UTXO.Data()))
    }
}
