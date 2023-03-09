//
//  CardUTXO.swift
//  Elysium
//
//  Created by Ivan Lele on 17.02.2023.
//

import SwiftUI

struct CardUTXOView: View {
    let utxo: UTXO
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(utxo.name)
                    .font(.headline)
                Text("#\(utxo.ID.description)")
                    .foregroundColor(.gray)
                Spacer()
                Text(utxo.symbol)
            }
            Spacer()
            HStack {
                Label("\(String(utxo.amount))", systemImage: "bitcoinsign.circle")
                Spacer()
                Text(utxo.status.description)
                    .foregroundColor(utxo.status.color)
            }
        }.padding()
    }
}

struct CardUTXO_Previews: PreviewProvider {
    static var previews: some View {
        CardUTXOView(utxo: UTXO.sampleData[0])
    }
}
