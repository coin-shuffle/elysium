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
}
