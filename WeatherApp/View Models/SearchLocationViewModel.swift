//
//  SearchLocationViewModel.swift
//  WeatherApp
//
//  Created by YK Poh on 22/06/2022.
//

import Foundation

protocol SearchLocationViewModelProtocol {
    var searchResults: Box<[SearchResultTVCViewModel]> { get }
    var errorMessage: Box<String?> { get }
    func getLocationSearchResult(query: String)
}

class SearchLocationViewModel: SearchLocationViewModelProtocol {
    let searchResults: Box<[SearchResultTVCViewModel]> = Box([])
    
    let errorMessage: Box<String?> = Box(nil)
                            
    var apiService: WeatherAPIServiceProtocol
    
    var notificationCenter: NotificationCenter
    
    init(apiService: WeatherAPIServiceProtocol = WeatherAPIService(), notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.apiService = apiService
        self.notificationCenter = notificationCenter
    }
    
    func getLocationSearchResult(query: String) {
        apiService.getLocationSearchResult(query: query) { [weak self] locations, error in
            guard let strongSelf = self else { return }
            
            if let locations = locations {
                
                strongSelf.searchResults.value = locations.compactMap {
                    SearchResultTVCViewModel(address: "\($0.name ?? ""), \($0.region ?? ""), \($0.country ?? "")", location: $0)
                }
                
            } else if let error = error {
                strongSelf.errorMessage.value = strongSelf.getAPIErrorMessage(error)
            }
        }
    }
    
    func postNotification(location: Location) {
        let dict:[String: Location] = [Constant.userInfoLocation: location]
        notificationCenter.post(name: Constant.updateLocationNotification, object: nil, userInfo: dict)
    }
    
    private func getAPIErrorMessage(_ error: WeatherAPIError) -> String {
        switch error {
        case .failedRequest(let message), .invalidData(let message), .invalidResponse(let message), .noData(let message):
            return message
        }
    }
}
