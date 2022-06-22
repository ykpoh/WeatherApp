//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by YK Poh on 20/06/2022.
//

import Foundation

protocol WeatherViewModelProtocol {
    var locationButtonTitle: Box<String?> { get }
    var temperature: Box<String?> { get }
    var conditionText: Box<String?> { get }
    var conditionIconImageURL: Box<URL?> { get }
    var feelsLikeTemperature: Box<String?> { get }
    var weatherDetails: Box<[WeatherDetailTVCViewModel]> { get }
    var error: Box<Error?> { get }
    func getCurrentWeather(latitude: Double, longitude: Double)
}

class WeatherViewModel: WeatherViewModelProtocol {
    var locationButtonTitle: Box<String?> = Box(nil)
    
    var temperature: Box<String?> = Box(nil)
    
    var conditionText: Box<String?> = Box(nil)
    
    var conditionIconImageURL: Box<URL?> = Box(nil)
    
    var feelsLikeTemperature: Box<String?> = Box(nil)
    
    var weatherDetails: Box<[WeatherDetailTVCViewModel]> = Box([])
    
    var error: Box<Error?> = Box(nil)
    
    var apiService: WeatherAPIServiceProtocol
    
    init(apiService: WeatherAPIServiceProtocol = WeatherAPIService()) {
        self.apiService = apiService
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation(_:)), name: Constant.updateLocationNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getCurrentWeather(latitude: Double, longitude: Double) {
        let query = "\(latitude),\(longitude)"
        apiService.getCurrentWeather(query: query) { [weak self] response, error in
            guard let strongSelf = self else { return }
            if let response = response {
                strongSelf.locationButtonTitle.value = response.location.name
                strongSelf.temperature.value = "\(response.current.tempC)°"
                strongSelf.conditionText.value = response.current.condition.text
                strongSelf.feelsLikeTemperature.value = "Feels like \(response.current.feelslikeC)°"
                strongSelf.conditionIconImageURL.value = URL(string: response.current.condition.icon.replacingOccurrences(of: "//", with: "https://"))
                
                var weatherDetailViewModels = [WeatherDetailTVCViewModel]()
                let wind = WeatherDetailTVCViewModel(title: "Wind", value: "\(response.current.windDir) \(response.current.windKph) km/h")
                weatherDetailViewModels.append(wind)
                
                let windGust = WeatherDetailTVCViewModel(title: "Wind Gust", value: "\(response.current.gustKph) km/h")
                weatherDetailViewModels.append(windGust)
                
                let humidity = WeatherDetailTVCViewModel(title: "Humidity", value: "\(response.current.humidity)%")
                weatherDetailViewModels.append(humidity)
                
                let pressure = WeatherDetailTVCViewModel(title: "Pressure", value: "\(response.current.pressureMB) mb")
                weatherDetailViewModels.append(pressure)
                
                let visibility = WeatherDetailTVCViewModel(title: "Visibility", value: "\(response.current.visKM) km")
                weatherDetailViewModels.append(visibility)
                
                strongSelf.weatherDetails.value = weatherDetailViewModels
                
            } else if let error = error {
                strongSelf.error.value = error
            }
        }
    }
    
    @objc func updateLocation(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let location = userInfo["location"] as? Location, let latitude = location.lat, let longitude = location.lon else { return }
        getCurrentWeather(latitude: latitude, longitude: longitude)
    }
    
}
