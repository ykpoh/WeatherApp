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
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: filename, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: data)
    }
}
