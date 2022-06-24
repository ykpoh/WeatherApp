//
//  Extensions.swift
//  WeatherAppTests
//
//  Created by YK Poh on 23/06/2022.
//

import Foundation
import XCTest

extension XCTestCase {
    func getModel<T>(filename: String) -> T where T: Codable {
        let data = getData(filename: filename)
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: data)
    }
    
    func getData(filename: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: filename, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
}
