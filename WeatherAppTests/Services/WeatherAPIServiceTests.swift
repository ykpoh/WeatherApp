//
//  WeatherAPIServiceTests.swift
//  WeatherAppTests
//
//  Created by YK Poh on 23/06/2022.
//

import XCTest
@testable import WeatherApp

class WeatherAPIServiceTests: XCTestCase {
    
    var sut: WeatherAPIService!
    var searchResultCache: NSCache<AnyObject, AnyObject>!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        searchResultCache = NSCache<AnyObject, AnyObject>()
        sut = WeatherAPIService(session: URLSession(configuration: configuration), searchResultCache: searchResultCache)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        searchResultCache = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGetCurrentWeatherSuccessfully() {
        // Set mock data
        let mockData = getData(filename: "Current")
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get current weather
        sut.getCurrentWeather(query: "110,220") { response, error in
            
            XCTAssertNil(error)
            
            let response = try! XCTUnwrap(response)
            
            let location = try! XCTUnwrap(response.location)
            XCTAssertEqual(location.name, "Seoul")
            XCTAssertEqual(location.region, "")
            XCTAssertEqual(location.country, "South Korea")
            XCTAssertEqual(location.lat, 37.57)
            XCTAssertEqual(location.lon, 127.0)
            XCTAssertEqual(location.tz_id, "Asia/Seoul")
            XCTAssertEqual(location.localtime_epoch, 1655986294)
            XCTAssertEqual(location.localtime, "2022-06-23 21:11")
            
            let current = try! XCTUnwrap(response.current)
            XCTAssertEqual(current.tempC, 25.0)
            XCTAssertEqual(current.windKph, 22.0)
            XCTAssertEqual(current.windDegree, 230)
            XCTAssertEqual(current.windDir, "SW")
            XCTAssertEqual(current.pressureMB, 997.0)
            XCTAssertEqual(current.humidity, 83)
            XCTAssertEqual(current.feelslikeC, 28.5)
            XCTAssertEqual(current.visKM, 4.8)
            XCTAssertEqual(current.gustKph, 35.3)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetCurrentWeatherWithError() {
        let url = URL(string: "\(sut.baseURLString)/current.json?key=\(sut.apiKey)&q=11,22")!
        // Set mock data
        let errorData = getData(filename: "Error")
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!, errorData)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get current weather
        sut.getCurrentWeather(query: "11,22") { response, error in
            
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            let errorMessage = self.getAPIErrorMessage(error!)
            XCTAssertEqual(errorMessage, "Failure response from WeatherAPI: 400")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testCallGetLocationSearchResultSuccessfully() {
        let url = URL(string: "\(sut.baseURLString)/search.json?key=\(sut.apiKey)&q=Lond")!
        // Set mock data
        let mockData = getData(filename: "Search")
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get current weather
        sut.getLocationSearchResult(query: "Lond") { locations, error in
            
            XCTAssertNil(error)
            
            let locations = try! XCTUnwrap(locations)
            
            if let searchResultHolder = self.searchResultCache.object(forKey: url as AnyObject) as? SearchResultHolder {
                self.verifyLocationData(locations: searchResultHolder.locations)
            }
            
            self.verifyLocationData(locations: locations)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetLocationSearchResultFromCache() {
        // Set mock data
        let mockLocations: [Location] = getModel(filename: "Search")
        let url = URL(string: "\(sut.baseURLString)/search.json?key=\(sut.apiKey)&q=Lond")!
        searchResultCache.setObject(SearchResultHolder(locations: mockLocations), forKey: url as AnyObject)
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get current weather
        sut.getLocationSearchResult(query: "Lond") { locations, error in
            
            XCTAssertNil(error)
            
            let locations = try! XCTUnwrap(locations)
            
            if let searchResultHolder = self.searchResultCache.object(forKey: url as AnyObject) as? SearchResultHolder {
                self.verifyLocationData(locations: searchResultHolder.locations)
            }
            
            self.verifyLocationData(locations: locations)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testCallGetLocationSearchResultWithError() {
        let url = URL(string: "\(sut.baseURLString)/search.json?key=\(sut.apiKey)&q=Lond")!
        // Set mock data
        let errorData = getData(filename: "Error")
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!, errorData)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get current weather
        sut.getLocationSearchResult(query: "Lond") { locations, error in
            
            XCTAssertNil(locations)
            XCTAssertNotNil(error)
            let errorMessage = self.getAPIErrorMessage(error!)
            XCTAssertEqual(errorMessage, "Failure response from WeatherAPI: 400")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    private func verifyLocationData(locations: [Location]) {
        XCTAssertFalse(locations.isEmpty)
        XCTAssertEqual(locations.count, 10)
        let first = locations.first!
        XCTAssertEqual(first.id, 2817507)
        XCTAssertEqual(first.name, "Vauxhall")
        XCTAssertEqual(first.region, "Lambeth, Greater London")
        XCTAssertEqual(first.country, "United Kingdom")
        XCTAssertEqual(first.lat, 51.49)
        XCTAssertEqual(first.lon, -0.12)
        XCTAssertEqual(first.url, "vauxhall-lambeth-greater-london-united-kingdom")
    }
    
    private func getAPIErrorMessage(_ error: WeatherAPIError) -> String {
        switch error {
        case .failedRequest(let message), .invalidData(let message), .invalidResponse(let message), .noData(let message):
            return message
        }
    }
    
}
