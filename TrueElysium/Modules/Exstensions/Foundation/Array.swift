//
//  Array.swift
//  TrueElysium
//
//  Created by Ivan Lele on 10.03.2023.
//

import Foundation


extension Array {
    func reversedIf(_ condition: Bool) -> [Self.Element] {
        if condition {
            return self.reversed()
        }
        
        return self
    }
}
