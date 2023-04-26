//
//  BigUInt.swift
//  TrueElysium
//
//  Created by Ivan Lele on 06.03.2023.
//

import Foundation
import BigInt

extension BigUInt {
    var hexEncode: [UInt8] {
        let buf = self.makeBytes()
        
        return Array(repeating: UInt8(0), count: 32-buf.count) + buf
    }
    
    func splitWithNominations(nominations: [BigUInt]) -> [BigUInt] {
        var remainingAmount = self
        
        let sortedNominations = nominations.sorted(by: { $0 > $1 })
        
        var result: [BigUInt] = []
        
        for nomination in sortedNominations {
            let count = remainingAmount / nomination
            
            result.append(contentsOf: Array(repeating: nomination, count: Int(count)))
            
            remainingAmount -= count * nomination
            
            if remainingAmount == 0 {
                break
            }
        }
        
        return result
    }
}
