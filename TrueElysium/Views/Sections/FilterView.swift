//
//  FilterView.swift
//  TrueElysium
//
//  Created by Ivan Lele on 09.03.2023.
//

import SwiftUI
import BigInt

struct FilterView: View {
    @ObservedObject var filterer: Filterer
    @Binding var isNewest: Bool
    
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
                Section(header: Text("Amount range")) {
                    RangedSliderView(
                        currentValue: $filterer.tokensAmounts,
                        sliderBounds: $filterer.tokensAmountsBounds
                    )
                    .padding()
                }
                Section(header: Text("Time creation")) {
                    Toggle(isOn: $isNewest) {
                        Text("Newest")
                    }
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            filterer: Filterer(),
            isNewest: .constant(false)
        )
    }
}
