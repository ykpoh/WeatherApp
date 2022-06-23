//
//  LocationTests.swift
//  WeatherAppTests
//
//  Created by YK Poh on 23/06/2022.
//

import XCTest
@testable import WeatherApp

class LocationTests: XCTestCase {
    
    var sut: [Location]!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = getModel(filename: "Search")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
    func testDecode_ReturnsLocation() {
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.count, 10)
        let first = sut.first!
        XCTAssertEqual(first.id, 2817507)
        XCTAssertEqual(first.name, "Vauxhall")
        XCTAssertEqual(first.region, "Lambeth, Greater London")
        XCTAssertEqual(first.country, "United Kingdom")
        XCTAssertEqual(first.lat, 51.49)
        XCTAssertEqual(first.lon, -0.12)
        XCTAssertEqual(first.url, "vauxhall-lambeth-greater-london-united-kingdom")
    }

}
