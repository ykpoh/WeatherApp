//
//  WeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by YK Poh on 24/06/2022.
//

import XCTest
@testable import WeatherApp

class WeatherViewModelTests: XCTestCase {
    
    var sut: WeatherViewModel!
    var mockAPIService: MockWeatherAPIService!
    var mockNotificationCenter: MockNotificationCenter!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        mockAPIService = MockWeatherAPIService()
        mockNotificationCenter = MockNotificationCenter()
        sut = WeatherViewModel(apiService: mockAPIService, notificationCenter: mockNotificationCenter)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockAPIService = nil
        mockNotificationCenter = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testInit_AddNotificationCenterObserver() {
        XCTAssertEqual(mockNotificationCenter.observer as? WeatherViewModel, sut)
        XCTAssertEqual(mockNotificationCenter.selector, #selector(sut.updateLocation(_:)))
        XCTAssertEqual(mockNotificationCenter.receiverName, Constant.updateLocationNotification)
        XCTAssertNil(mockNotificationCenter.receiverObject)
    }
    
    func testGetCurrentWeather_ReturnsWeatherDetails()
    {
        let currentWeather: CurrentWeather = getModel(filename: "Current")
        mockAPIService.getCurrentWeatherResponse = currentWeather
        
        sut.getCurrentWeather(latitude: 110, longitude: 220)
        
        XCTAssertNil(sut.errorMessage.value)
        XCTAssertEqual(mockAPIService.getCurrentWeatherQuery, "110.0,220.0")
        XCTAssertEqual(sut.locationButtonTitle.value, "Seoul")
        XCTAssertEqual(sut.temperature.value, "25.0°")
        XCTAssertEqual(sut.conditionText.value, "Light rain")
        XCTAssertEqual(sut.feelsLikeTemperature.value, "Feels like 28.5°")
        XCTAssertEqual(sut.conditionIconImageURL.value, URL(string: "https://cdn.weatherapi.com/weather/64x64/night/296.png"))
        
        let weatherDetails = sut.weatherDetails.value
        XCTAssertFalse(weatherDetails.isEmpty)
        XCTAssertEqual(weatherDetails.count, 5)
        let wind = try! XCTUnwrap(weatherDetails.first)
        XCTAssertEqual(wind.title.value, "Wind")
        XCTAssertEqual(wind.value.value, "SW 22.0 km/h")
        
        let windGust = try! XCTUnwrap(weatherDetails[1])
        XCTAssertEqual(windGust.title.value, "Wind Gust")
        XCTAssertEqual(windGust.value.value, "35.3 km/h")
        
        let humidity = try! XCTUnwrap(weatherDetails[2])
        XCTAssertEqual(humidity.title.value, "Humidity")
        XCTAssertEqual(humidity.value.value, "83.0%")
        
        let pressure = try! XCTUnwrap(weatherDetails[3])
        XCTAssertEqual(pressure.title.value, "Pressure")
        XCTAssertEqual(pressure.value.value, "997.0 mb")
        
        let visibility = try! XCTUnwrap(weatherDetails[4])
        XCTAssertEqual(visibility.title.value, "Visibility")
        XCTAssertEqual(visibility.value.value, "4.8 km")
        
        XCTAssertFalse(sut.showSpinner.value)
    }
    
    func testGetCurrentWeather_ReturnsError() {
        let error: WeatherAPIError = .invalidResponse(message: "Invalid response")
        mockAPIService.getCurrentWeatherError = error
        
        sut.getCurrentWeather(latitude: 54, longitude: -43)
        
        XCTAssertEqual(mockAPIService.getCurrentWeatherQuery, "54.0,-43.0")
        XCTAssertNil(sut.locationButtonTitle.value)
        XCTAssertNil(sut.temperature.value)
        XCTAssertNil(sut.conditionText.value)
        XCTAssertNil(sut.feelsLikeTemperature.value)
        XCTAssertNil(sut.conditionIconImageURL.value)
        XCTAssertTrue(sut.weatherDetails.value.isEmpty)
        XCTAssertFalse(sut.showSpinner.value)
        XCTAssertEqual(sut.errorMessage.value, "Invalid response")
    }
    
    func testPostUpdateLocationNotification_GetCurrentWeather() {
        let locations: [Location] = getModel(filename: "Search")
        let dict:[String: Location] = [Constant.userInfoLocation: locations.first!]
        XCTAssertNil(mockAPIService.getCurrentWeatherQuery)
        
        mockNotificationCenter.post(name: Constant.updateLocationNotification, object: nil, userInfo: dict)
        
        XCTAssertEqual(mockAPIService.getCurrentWeatherQuery, "51.49,-0.12")
        
    }
}
