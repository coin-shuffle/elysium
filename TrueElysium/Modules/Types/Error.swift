//
//  Error.swift
//  TrueElysium
//
//  Created by Ivan Lele on 26.02.2023.
//

import Foundation

public enum UTXOsViewError: LocalizedError {
    case invalidTokenAddress
    case invalidAmount
    case failedToGetTokenNameAndSymbol
    case failedToCreateUTXO
    case invalidPrivateKey
    
    public var errorDescription: String? {
        get {
            switch self {
            case .invalidTokenAddress:
                return NSLocalizedString("Invalid token address", comment: "")
            case .invalidAmount:
                return NSLocalizedString("Invalid amount", comment: "")
            case .failedToGetTokenNameAndSymbol:
                return NSLocalizedString("Failed to get token name and symbol", comment: "")
            case .failedToCreateUTXO:
                return NSLocalizedString("Failed to create UTXO", comment: "")
            case .invalidPrivateKey:
                return NSLocalizedString("Invalid private key", comment: "")
            }
        }
    }
    
    public var failureReason: String? {
        get {
            switch self {
            case .invalidTokenAddress:
                return"The provided token address is invalid."
            case .invalidAmount:
                return "The provided amount is invalid."
            case .failedToGetTokenNameAndSymbol:
                return "Failed to get the name and symbol for the provided token."
            case .failedToCreateUTXO:
                return "Failed to create UXTO with the given data."
            case .invalidPrivateKey:
                return "The provided private key is invalid."
            }
        }
    }
    
    public var helpAnchor: String? {
        get {
            switch self {
            case .invalidTokenAddress:
                return "Check that the provided token address is correct."
            case .invalidAmount:
                return "Check that the provided amount is a valid number."
            case .failedToGetTokenNameAndSymbol:
                return "Check the network connection and try again."
            case .failedToCreateUTXO:
                return "Check the failure reason via etherscan."
            case .invalidPrivateKey:
                return "Check that the provided private key is correct."
            }
        }
    }
        
    public var recoverySuggestion: String? {
        get {
            switch self {
            case .invalidTokenAddress:
                return "Provide a valid token address."
            case .invalidAmount:
                return "Provide a valid amount."
            case .failedToGetTokenNameAndSymbol:
                return "Try again later or contact support if the problem persists."
            case .failedToCreateUTXO:
                return "Try check out your funds."
            case .invalidPrivateKey:
                return "Provide a valid private key."
            }
        }
    }
}

public enum EthereumClientError: LocalizedError {
    case failedToConnect
    case invalidPrivateKey
    case invalidContract
    case failedToCreateTx
    case txFailed
    case failedToEncodeWithdrawSignatureData
    
    public var errorDescription: String? {
        switch self {
        case .failedToConnect: return "Failed to connect to the Ethereum node"
        case .invalidPrivateKey: return "Invalid private key"
        case .invalidContract: return "Invalid contract"
        case .failedToCreateTx: return "Failed to create a transaction"
        case .txFailed: return "Transaction failed"
        case .failedToEncodeWithdrawSignatureData: return "Somehow encoding data were corrupted"
        }
    }
}
