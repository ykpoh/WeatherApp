//
//  SearchResultTVCViewModel.swift
//  WeatherApp
//
//  Created by YK Poh on 22/06/2022.
//

import Foundation

class SearchResultTVCViewModel {
    let address: Box<String?> = Box(nil)
    let location: Box<Location?> = Box(nil)
    
    init(address: String? = nil, location: Location? = nil) {
        self.address.value = address
        self.location.value = location
    }
}

extension SearchResultTVCViewModel: Equatable {
    static func == (lhs: SearchResultTVCViewModel, rhs: SearchResultTVCViewModel) -> Bool {
        lhs.location.value == rhs.location.value
    }
}
