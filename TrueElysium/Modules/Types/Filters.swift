//
//  Filters.swift
//  TrueElysium
//
//  Created by Ivan Lele on 09.03.2023.
//

import Foundation
import Web3

struct StatusFilter: Identifiable {
    let id: Int
    let value: UTXO.Status
    var selected: Bool
}

class Filterer: ObservableObject {
    @Published var statuses: [StatusFilter] = [
        StatusFilter(id: 0, value: .failed, selected: true),
        StatusFilter(id: 1, value: .creating, selected: true),
        StatusFilter(id: 2, value: .created, selected: true),
        StatusFilter(id: 3, value: .searching, selected: true),
        StatusFilter(id: 4, value: .shuffling, selected: true),
        StatusFilter(id: 5, value: .shuffled, selected: true)
    ]
    
    @Published var tokenName = ""
    
    @Published var onlyMine = false
    
    func toggle(statusFilter: StatusFilter) {
        self.statuses[statusFilter.id].selected.toggle()
    }
    
    func isSelected(status: UTXO.Status) -> Bool {
        for _status in statuses {
            if _status.value == status {
                return _status.selected
            }
        }
        
        return false
    }
    
    func isFitName(name: String) -> Bool {
        if tokenName == "" {
            return true
        }
        
        return tokenName == name
    }
    
    func isMine(owner: EthereumAddress, user: EthereumAddress?) -> Bool {
        if user == nil {
            return false
        }
        
        return owner == user
    }
    
    func filter(utxo: UTXO, user: EthereumAddress?) -> Bool {
        guard isSelected(status: utxo.status) else {
            return false
        }
        
        if onlyMine {
            return isMine(owner: utxo.owner, user: user) && isFitName(name: utxo.name)
        }
        
        return isFitName(name: utxo.name)
    }
}
