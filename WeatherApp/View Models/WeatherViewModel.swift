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
    var errorMessage: Box<String?> { get }
    var showSpinner: Box<Bool> { get }
    func getCurrentWeather(latitude: Double, longitude: Double)
    func updateLocation(_ notification: Notification)
}

class WeatherViewModel: WeatherViewModelProtocol {
    var locationButtonTitle: Box<String?> = Box(nil)
    
    var temperature: Box<String?> = Box(nil)
    
    var conditionText: Box<String?> = Box(nil)
    
    var conditionIconImageURL: Box<URL?> = Box(nil)
    
    var feelsLikeTemperature: Box<String?> = Box(nil)
    
    var weatherDetails: Box<[WeatherDetailTVCViewModel]> = Box([])
    
    var errorMessage: Box<String?> = Box(nil)
    
    var showSpinner: Box<Bool> = Box(false)
    
    var apiService: WeatherAPIServiceProtocol
    
    init(apiService: WeatherAPIServiceProtocol = WeatherAPIService()) {
        self.apiService = apiService
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation(_:)), name: Constant.updateLocationNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getCurrentWeather(latitude: Double, longitude: Double) {
        showSpinner.value = true
        let query = "\(latitude),\(longitude)"
        apiService.getCurrentWeather(query: query) { [weak self] response, error in
            guard let strongSelf = self else { return }
            strongSelf.showSpinner.value = false
            
            if let response = response {
                strongSelf.parseCurrentWeatherResponse(response)
            } else if let error = error {
                strongSelf.errorMessage.value = strongSelf.getAPIErrorMessage(error)
            }
        }
    }
    
    @objc func updateLocation(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let location = userInfo[Constant.userInfoLocation] as? Location, let latitude = location.lat, let longitude = location.lon else { return }
        getCurrentWeather(latitude: latitude, longitude: longitude)
    }
    
    private func parseCurrentWeatherResponse(_ response: CurrentWeather) {
        var weatherDetailViewModels = [WeatherDetailTVCViewModel]()
        
        locationButtonTitle.value = response.location?.name
        
        if let current = response.current {
            temperature.value = "\(current.tempC ?? 0.0)°"
            conditionText.value = current.condition?.text
            feelsLikeTemperature.value = "Feels like \(current.feelslikeC ?? 0.0)°"
            conditionIconImageURL.value = URL(string: current.condition?.icon?.replacingOccurrences(of: "//", with: "https://") ?? "")
            
            let wind = WeatherDetailTVCViewModel(title: "Wind", value: "\(current.windDir ?? "") \(current.windKph ?? 0.0) km/h")
            weatherDetailViewModels.append(wind)
            
            let windGust = WeatherDetailTVCViewModel(title: "Wind Gust", value: "\(current.gustKph ?? 0.0) km/h")
            weatherDetailViewModels.append(windGust)
            
            let humidity = WeatherDetailTVCViewModel(title: "Humidity", value: "\(current.humidity ?? 0.0)%")
            weatherDetailViewModels.append(humidity)
            
            let pressure = WeatherDetailTVCViewModel(title: "Pressure", value: "\(current.pressureMB ?? 0.0) mb")
            weatherDetailViewModels.append(pressure)
            
            let visibility = WeatherDetailTVCViewModel(title: "Visibility", value: "\(current.visKM ?? 0.0) km")
            weatherDetailViewModels.append(visibility)
        }
        
        weatherDetails.value = weatherDetailViewModels
    }
    
    private func getAPIErrorMessage(_ error: WeatherAPIError) -> String {
        switch error {
        case .failedRequest(let message), .invalidData(let message), .invalidResponse(let message), .noData(let message):
            return message
        }
    }
    
}
