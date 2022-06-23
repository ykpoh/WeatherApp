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
    
    func testDecode_ReturnsLocation() {
        let location = try! XCTUnwrap(sut.location)
        XCTAssertEqual(location.name, "Seoul")
        XCTAssertEqual(location.region, "")
        XCTAssertEqual(location.country, "South Korea")
        XCTAssertEqual(location.lat, 37.57)
        XCTAssertEqual(location.lon, 127.0)
        XCTAssertEqual(location.tz_id, "Asia/Seoul")
        XCTAssertEqual(location.localtime_epoch, 1655986294)
        XCTAssertEqual(location.localtime, "2022-06-23 21:11")
    }

    func testDecode_ReturnsCurrent() {
        let current = try! XCTUnwrap(sut.current)
        XCTAssertEqual(current.tempC, 25.0)
        XCTAssertEqual(current.windKph, 22.0)
        XCTAssertEqual(current.windDegree, 230)
        XCTAssertEqual(current.windDir, "SW")
        XCTAssertEqual(current.pressureMB, 997.0)
        XCTAssertEqual(current.humidity, 83)
        XCTAssertEqual(current.feelslikeC, 28.5)
        XCTAssertEqual(current.visKM, 4.8)
        XCTAssertEqual(current.gustKph, 35.3)
        
        let condition = try! XCTUnwrap(current.condition)
        XCTAssertEqual(condition.code, 1183)
        XCTAssertEqual(condition.text, "Light rain")
        XCTAssertEqual(condition.icon, "//cdn.weatherapi.com/weather/64x64/night/296.png")
    }
}
