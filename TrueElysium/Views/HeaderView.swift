//
//  HeaderView.swift
//  TrueElysium
//
//  Created by Ivan Lele on 02.03.2023.
//

import SwiftUI

struct HeaderView: View {
    @Binding var isPresentChangePrivateKey: Bool
    
    var body: some View {
        ZStack {
            Text("UTXOs")
                .font(.bold(.title)())
            HStack {
                Spacer()
                Button(action: {
                    isPresentChangePrivateKey = true
                }) {
                    Image(systemName: "key")
                        .padding()
                }
            }
            
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(isPresentChangePrivateKey: .constant(true))
    }
}