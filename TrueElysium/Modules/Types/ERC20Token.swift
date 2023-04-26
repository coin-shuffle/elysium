//
//  ERC20Token.swift
//  TrueElysium
//
//  Created by Ivan Lele on 25.04.2023.
//

import Foundation


public enum ERC20Token: CaseIterable, CustomStringConvertible {
    case USDT
    case BNB
    case USDC
    case stETH
    case HEX
    case MATIC
    case anyLTC
    case BUSD
    case SHIB
    case THETA
    case CUSTOM
    
    public var description: String {
        switch self {
        case .USDT: return "Tether USD (USDT)"
        case .BNB: return "BNB (BNB)"
        case .USDC: return "USD Coin (USDC)"
        case .stETH: return "stETH (stETH)"
        case .HEX: return "HEX (HEX)"
        case .MATIC: return "MATIC Token (MATIC)"
        case .anyLTC: return "ANY Litecoin (anyLTC)"
        case .BUSD: return "Binance USD (BUSD)"
        case .SHIB: return "SHIBA INU (SHIB)"
        case .THETA: return "Theta Token (THETA)"
        case .CUSTOM: return "Custom"
        }
    }
    
    var contractAddress: String {
        switch self {
        case .USDT: return "0xdac17f958d2ee523a2206206994597c13d831ec7"
        case .BNB: return "0xB8c77482e45F1F44dE1745F52C74426C631bDD52"
        case .USDC: return "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
        case .stETH: return "0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84"
        case .HEX: return "0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39"
        case .MATIC: return "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0"
        case .anyLTC: return "0x0aBCFbfA8e3Fda8B7FBA18721Caf7d5cf55cF5f5"
        case .BUSD: return "0x4Fabb145d64652a948d72533023f6E7A623C7C53"
        case .SHIB: return "0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE"
        case .THETA: return "0x3883f5e181fccaF8410FA61e12b59BAd963fb645"
        case .CUSTOM: return "0x0000000000000000000000000000000000000000"
        }
    }
}

public extension ERC20Token {
    
}
