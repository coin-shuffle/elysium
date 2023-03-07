//
//  Nonce.swift
//  TrueElysium
//
//  Created by Ivan Lele on 02.03.2023.
//

import Foundation

typealias Nonce = [UInt8]

extension Nonce {
    init(length: UInt64 = 32) {
        self = []
        for _ in 0..<length {
            self.append(UInt8.random(in: 0...255))
        }
    }
}
