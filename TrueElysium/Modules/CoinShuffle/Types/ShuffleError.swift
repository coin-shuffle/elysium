//
//  ShuffleError.swift
//  TrueElysium
//
//  Created by Ivan Lele on 05.03.2023.
//

import Foundation

enum ClientError: Error {
    case failedToUpdateShuffleInfo
    case failedToEncryptOutputs
    case failedToSignOutputs
    case failedToShuffle
}
