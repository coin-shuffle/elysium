//
//  TrueElysiumTests.swift
//  TrueElysiumTests
//
//  Created by Ivan Lele on 21.02.2023.
//

import XCTest
import BigInt
@testable import TrueElysium

final class TrueElysiumTests: XCTestCase {
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}
    
    func testSplit() throws {
        let amount: BigUInt = 16
        
        print("Amounts: \(amount.splitWithNominations(nominations: [1_000_000, 100_000, 10_000, 5_000, 1_000, 500, 200, 100, 50, 20, 10, 5, 2, 1]))")
    }
}
