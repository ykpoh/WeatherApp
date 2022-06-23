//
//  CurrentWeatherTests.swift
//  WeatherAppTests
//
//  Created by YK Poh on 23/06/2022.
//

import XCTest
@testable import WeatherApp

class CurrentWeatherTests: XCTestCase {
    
    var sut: CurrentWeather!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = getModel(filename: "Current")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
    func testDecode_ReturnsAccurateLocation() {
        XCTAssertEqual(sut.location.name, "Seoul")
        XCTAssertEqual(sut.location.region, "")
        XCTAssertEqual(sut.location.country, "South Korea")
        XCTAssertEqual(sut.location.lat, 37.57)
        XCTAssertEqual(sut.location.lon, 127.0)
    }

}
