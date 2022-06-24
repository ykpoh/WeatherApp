//
//  SearchLocationViewModelTests.swift
//  WeatherAppTests
//
//  Created by YK Poh on 24/06/2022.
//

import XCTest
@testable import WeatherApp

class SearchLocationViewModelTests: XCTestCase {
    
    var sut: SearchLocationViewModel!
    var mockAPIService: MockWeatherAPIService!
    var mockNotificationCenter: MockNotificationCenter!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        mockAPIService = MockWeatherAPIService()
        mockNotificationCenter = MockNotificationCenter()
        sut = SearchLocationViewModel(apiService: mockAPIService, notificationCenter: mockNotificationCenter)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockAPIService = nil
        mockNotificationCenter = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGetLocationSearchResult_ReturnsLocations() {
        let locations: [Location] = getModel(filename: "Search")
        mockAPIService.getLocationSearchResultResponse = locations
        
        sut.getLocationSearchResult(query: "Lond")
        
        XCTAssertNil(sut.errorMessage.value)
        XCTAssertEqual(mockAPIService.getLocationSearchResultQuery, "Lond")
        XCTAssertFalse(sut.searchResults.value.isEmpty)
        XCTAssertEqual(sut.searchResults.value.count, 10)
        XCTAssertEqual(sut.searchResults.value.first?.location.value, locations.first)
    }
    
    func testGetLocationSearchResult_ReturnsError() {
        let error: WeatherAPIError = .invalidResponse(message: "Invalid response")
        mockAPIService.getLocationSearchResultError = error
        
        sut.getLocationSearchResult(query: "Bei")
        
        XCTAssertEqual(mockAPIService.getLocationSearchResultQuery, "Bei")
        XCTAssertEqual(sut.errorMessage.value, "Invalid response")
        XCTAssertTrue(sut.searchResults.value.isEmpty)
    }
    
    func testPostNotificationWithLocation() {
        let locations: [Location] = getModel(filename: "Search")
        let selectedLocation = locations.last!
        sut.postNotification(location: selectedLocation)
        XCTAssertEqual(mockNotificationCenter.senderName, Constant.updateLocationNotification)
        XCTAssertNil(mockNotificationCenter.senderObject)
        let userInfo: [AnyHashable: Any] = try! XCTUnwrap(mockNotificationCenter.userInfo)
        let location = userInfo[Constant.userInfoLocation] as! Location
        XCTAssertEqual(location, selectedLocation)
    }

}
