//
//  Mocks.swift
//  WeatherAppTests
//
//  Created by YK Poh on 23/06/2022.
//

import Foundation
import XCTest
@testable import WeatherApp

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Received unexpected request with no handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
    }
}

class MockNotificationCenter: NotificationCenter {
    var observer: Any?
    var selector: Selector?
    var receiverName: NSNotification.Name?
    var senderName: NSNotification.Name?
    var receiverObject: Any?
    var senderObject: Any?
    var userInfo: [AnyHashable: Any]?
    
    override func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        super.addObserver(observer, selector: aSelector, name: aName, object: anObject)
        self.observer = observer
        self.selector = aSelector
        self.receiverName = aName
        self.receiverObject = anObject
    }
    
    override func removeObserver(_ observer: Any) {
        super.removeObserver(observer)
        self.observer = nil
    }
    
    override func post(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        super.post(name: aName, object: anObject, userInfo: aUserInfo)
        self.senderName = aName
        self.senderObject = anObject
        self.userInfo = aUserInfo
    }
}

class MockWeatherAPIService: WeatherAPIServiceProtocol {
    var getCurrentWeatherQuery: String?
    var getCurrentWeatherResponse: CurrentWeather?
    var getCurrentWeatherError: WeatherAPIError?
    var getLocationSearchResultQuery: String?
    var getLocationSearchResultResponse: [Location]?
    var getLocationSearchResultError: WeatherAPIError?
    
    func getCurrentWeather(query: String, completion: @escaping (CurrentWeather?, WeatherAPIError?) -> ()) {
        getCurrentWeatherQuery = query
        if let response = getCurrentWeatherResponse {
            completion(response, nil)
        } else {
            completion(nil, getCurrentWeatherError)
        }
    }
    
    func getLocationSearchResult(query: String, completion: @escaping ([Location]?, WeatherAPIError?) -> ()) {
        getLocationSearchResultQuery = query
        if let response = getLocationSearchResultResponse {
            completion(response, nil)
        } else {
            completion(nil, getLocationSearchResultError)
        }
    }
}
