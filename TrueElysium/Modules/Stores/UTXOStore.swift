//
//  UTXOStore.swift
//  Don't you see any weirds?
//
//  Created by Ivan Lele on 17.02.2023.
//

import Foundation
import SwiftUI

class UTXOStore: ObservableObject {
    @Published var utxos: [UTXO] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("utxos.data")
    }
    
    static func load(completion: @escaping (Result<[UTXO], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let _utxos = try JSONDecoder().decode([UTXO].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(_utxos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(utxos: [UTXO], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(utxos)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(utxos.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

