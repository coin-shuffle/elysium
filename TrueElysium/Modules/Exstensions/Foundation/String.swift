//
//  String.swift
//  TrueElysium
//
//  Created by Ivan Lele on 26.02.2023.
//

import Foundation

public extension String {
    func removeSubstringExceptFirst(_ substring: String) -> String {
        guard let firstIndex = self.range(of: substring)?.upperBound else {
            return self
        }
        
        let restOfTheString = self.suffix(from: firstIndex)
        return substring + restOfTheString.replacingOccurrences(
            of: substring,
            with: ""
        )
    }
    
    func contraction(maxLength: UInt) -> String {
        if (self.count <= maxLength) {
            return self
        }
        
        
        let endIndex = self.index(self.startIndex, offsetBy: Int(maxLength - 3))
        let startIndex = self.index(self.startIndex, offsetBy: Int(self.count - 2))
        
        return "\(self[...endIndex])...\(self[startIndex...])"
    }
}
