//
//  PrivateKey.swift
//  TrueElysium
//
//  Created by Ivan Lele on 03.03.2023.
//

import Foundation
import SwiftyRSA

extension PrivateKey {
    var publicKey: PublicKey {
        try! PublicKey(reference: SecKeyCopyPublicKey(self.reference)!)
    }
}
