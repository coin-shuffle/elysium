//
//  ChangePrivateKeyView.swift
//  Elysium
//
//  Created by Ivan Lele on 19.02.2023.
//

import SwiftUI

struct ChangePrivateKeyView: View {
    @Binding var privateKey: String
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Private key:")) {
                    TextField("000000000000000000000000000000000000000000", text: $privateKey)
                }
            }
        }
    }
}

struct ChangePrivateKeyView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePrivateKeyView(
            privateKey: .constant("")
        )
    }
}

