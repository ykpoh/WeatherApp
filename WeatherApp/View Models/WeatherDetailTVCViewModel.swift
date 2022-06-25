//
//  WeatherDetailTVCViewModel.swift
//  WeatherApp
//
//  Created by YK Poh on 21/06/2022.
//

import Foundation

class WeatherDetailTVCViewModel {
    let title: Box<String?> = Box(nil)
    let value: Box<String?> = Box(nil)
    
    init(title: String? = nil, value: String? = nil) {
        self.title.value = title
        self.value.value = value
    }
}

extension WeatherDetailTVCViewModel: Equatable {
    static func == (lhs: WeatherDetailTVCViewModel, rhs: WeatherDetailTVCViewModel) -> Bool {
        lhs.title.value == rhs.title.value && lhs.value.value == rhs.value.value
    }
}
