//
//  ImageLoaderTests.swift
//  WeatherAppTests
//
//  Created by YK Poh on 25/06/2022.
//

import XCTest
@testable import WeatherApp

class ImageLoaderTests: XCTestCase {
    
    var sut: ImageLoader!
    var imageCache: NSCache<AnyObject, AnyObject>!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = ImageLoader()
        imageCache = NSCache<AnyObject, AnyObject>()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        sut.cacheStorage = imageCache
        sut.session = URLSession(configuration: configuration)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        imageCache = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoadImageFromURL_SetImageAndSaveInImageCache() {
        // Set mock data
        let url = URL(string: "https://cdn.weatherapi.com/weather/64x64/night/110.png")!
        let data = UIImage(systemName: "multiply.circle.fill")!.pngData()!
        let image = UIImage(data: data)!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), data)
        }
        
        let exp = expectation(description: "loading image url")
        
        sut.loadImageWithUrl(url)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
            XCTAssertNotNil(self.sut.image)
            XCTAssertEqual(self.sut.image?.pngData(), image.pngData())
            let cachedImage = try! XCTUnwrap(self.imageCache.object(forKey: url as AnyObject) as? UIImage)
            XCTAssertEqual(cachedImage.pngData(), image.pngData())
            XCTAssertFalse(self.sut.activityIndicator.isAnimating)
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testLoadImageFromURL_ReturnsError() {
        // Set mock data
        let url = URL(string: "https://cdn.weatherapi.com/weather/64x64/night/110.png")!
        let errorData = getData(filename: "Error")
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!, errorData)
        }
        
        let exp = expectation(description: "loading image url with error")
        
        sut.loadImageWithUrl(url)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
            XCTAssertNil(self.sut.image)
            XCTAssertNil(self.imageCache.object(forKey: url as AnyObject))
            XCTAssertFalse(self.sut.activityIndicator.isAnimating)
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testLoadImageFromImageCache() {
        let url = URL(string: "https://cdn.weatherapi.com/weather/64x64/night/296.png")!
        let image = UIImage(systemName: "house")!
        imageCache.setObject(image, forKey: url as AnyObject)
        
        sut.loadImageWithUrl(url)
        
        XCTAssertNotNil(sut.image)
        XCTAssertEqual(sut.image, image)
        XCTAssertFalse(sut.activityIndicator.isAnimating)
    }

}
