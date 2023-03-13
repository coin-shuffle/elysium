//
//  Future.swift
//  TrueElysium
//
//  Created by Ivan Lele on 06.03.2023.
//

import Foundation
import Combine

extension Future where Failure == Error {
    convenience init(asyncFunc: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let result = try await asyncFunc()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
