//
//  WeatherAPIService.swift
//  WeatherApp
//
//  Created by YK Poh on 20/06/2022.
//

import Foundation

enum WeatherAPIError: Error {
    case invalidResponse(message: String)
    case noData(message: String)
    case failedRequest(message: String)
    case invalidData(message: String)
}

protocol WeatherAPIServiceProtocol {
    func getCurrentWeather(query: String, completion: @escaping (CurrentWeather?, WeatherAPIError?) -> ())
}

class WeatherAPIService: WeatherAPIServiceProtocol {
    let baseURLString = "https://api.weatherapi.com/v1"
    let apiKey = "346fa87e7ac74727a1a72424222405"
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getCurrentWeather(query: String, completion: @escaping (CurrentWeather?, WeatherAPIError?) -> ()) {
        let url = URL(string: "\(baseURLString)/current.json?key=\(apiKey)&q=\(query)")!

        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if let error = strongSelf.checkErrors(data, response, error) {
                    completion(nil, error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(CurrentWeather.self, from: data!)
                    completion(model, nil)
                } catch {
                    completion(nil, .invalidData(message: "Unable to decode WeatherAPI response: \(error.localizedDescription)"))
                }
            }
        }.resume()
    }
    
    private func checkErrors(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> WeatherAPIError? {
        guard error == nil else {
            return .failedRequest(message: "Failed request from WeatherAPI: \(error!.localizedDescription)")
        }
        
        guard data != nil else {
            return .noData(message: "No data returned from WeatherAPI")
        }
        
        guard let response = response as? HTTPURLResponse else {
            return .invalidResponse(message: "Unable to process WeatherAPI response")
        }
        
        guard response.statusCode == 200 else {
            return .failedRequest(message: "Failure response from WeatherAPI: \(response.statusCode)")
        }
        
        return nil
    }
}
