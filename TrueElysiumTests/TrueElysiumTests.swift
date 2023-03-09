//
//  TrueElysiumTests.swift
//  TrueElysiumTests
//
//  Created by Ivan Lele on 21.02.2023.
//

import XCTest
@testable import TrueElysium

final class TrueElysiumTests: XCTestCase {
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}
    
    func testConfig() throws {
        try parseConfig()
    }
}
