//
//  FilterView.swift
//  TrueElysium
//
//  Created by Ivan Lele on 09.03.2023.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var filterer: Filterer
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Status")) {
                    ForEach(filterer.statuses) {filter in
                        HStack {
                            Image(systemName: filter.selected ? "checkmark.circle.fill" : "circle")
                            Text(filter.value.description)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            filterer.toggle(statusFilter: filter)
                        }
                    }
                }
                Section(header: Text("Token name")) {
                    TextField("Tether, e.g.", text: $filterer.tokenName)
                }
                Section(header: Text("Ownership")) {
                    Toggle(isOn: $filterer.onlyMine) {
                        Text("Mine")
                    }
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            filterer: Filterer()
        )
    }
}
