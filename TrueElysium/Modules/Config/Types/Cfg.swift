//
//  Cfg.swift
//  TrueElysium
//
//  Created by Ivan Lele on 08.03.2023.
//

import Foundation
import Yams

public struct NetConfig: Codable {
    public let httpProviderURL: String
    public let utxoStorageAddress: String
    public let networkID: UInt64
}

public struct CoinShuffleSvcConfig: Codable {
    public let grpcHost: String
    public let port: Int
}

public struct AppConfig: Codable {
    public let NetConfig: NetConfig
    public let CoinShuffleSvcConfig: CoinShuffleSvcConfig
}

