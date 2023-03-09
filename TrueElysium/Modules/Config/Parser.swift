//
//  Parser.swift
//  TrueElysium
//
//  Created by Ivan Lele on 08.03.2023.
//

import Foundation
import Yams

func parseConfig() -> AppConfig {
    let filePath = Bundle.main.path(forResource: "Config", ofType: "yaml")
    let data = try! String (try! Data(contentsOf: URL(fileURLWithPath: filePath!)))
    
    return try! YAMLDecoder().decode(AppConfig.self, from: data)
}
