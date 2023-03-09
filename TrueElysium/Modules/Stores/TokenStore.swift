//
//  TokenStore.swift
//  TrueElysium
//
//  Created by Ivan Lele on 09.03.2023.
//

import Foundation
import Web3

struct Token: Codable {
    let address: EthereumAddress
    let name: String
    let symbol: String
}

public class TokenStore: ObservableObject {
    @Published var tokens: [Token] = []
    let ethereumClient: EthereumClient
    
    init(ethereumClient: EthereumClient) {
        self.ethereumClient = ethereumClient
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("tokens.data")
    }
    
    func getToken(_ tokenAddress: EthereumAddress) async throws -> Token {
        guard let token = tokens.first else {
            let (name, symbol) = try await ethereumClient.getETC20NameAndSymbol(tokenAddress)
            
            let token = Token(
                address: tokenAddress,
                name: name,
                symbol: symbol
            )
            
            tokens.append(token)
            return token
        }
        
        return token
    }
    
    static func load(completion: @escaping (Result<[Token], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let _tokens = try JSONDecoder().decode([Token].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(_tokens))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(tokens: [Token], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(tokens)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(tokens.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
