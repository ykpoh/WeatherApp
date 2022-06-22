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
    
    init(apiService: WeatherAPIServiceProtocol = WeatherAPIService()) {
        self.apiService = apiService
    }
    
    func getLocationSearchResult(query: String) {
        apiService.getLocationSearchResult(query: query) { [weak self] locations, error in
            guard let strongSelf = self else { return }
            
            if let locations = locations {
                
                strongSelf.searchResults.value = locations.compactMap {
                    SearchResultTVCViewModel(address: "\($0.name ?? ""), \($0.region ?? ""), \($0.country ?? "")", location: $0)
                }
                
            } else if let error = error {
                
            }
        }
    }
    
    func postNotification(location: Location) {
        let dict:[String: Location] = ["location": location]
        NotificationCenter.default.post(name: Constant.updateLocationNotification, object: nil, userInfo: dict)
    }
}
