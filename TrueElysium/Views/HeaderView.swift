//
//  HeaderView.swift
//  TrueElysium
//
//  Created by Ivan Lele on 02.03.2023.
//

import SwiftUI

struct HeaderView: View {
    @Binding var isPresentChangePrivateKey: Bool
    @Binding var isPresentFilterSelection: Bool
    
    var body: some View {
        HStack {
            Text("UTXOs")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                isPresentFilterSelection = true
            }) {
                Image(systemName: "line.horizontal.3.decrease.circle")
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            Button(action: {
                isPresentChangePrivateKey = true
            }) {
                Image(systemName: "key.fill")
                    .font(.title)
                    .rotationEffect(.degrees(isPresentChangePrivateKey ? 90 : 0))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(.blue)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            isPresentChangePrivateKey: .constant(true),
            isPresentFilterSelection: .constant(true)
        )
    }
}
