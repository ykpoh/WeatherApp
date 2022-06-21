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
