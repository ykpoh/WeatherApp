//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by YK Poh on 20/06/2022.
//

import Foundation

// MARK: - Welcome
struct CurrentWeather: Codable, Equatable {
    var location: Location?
    var current: Current?
}

// MARK: - Current
struct Current: Codable, Equatable {
    let lastUpdatedEpoch: Int?
    let lastUpdated: String?
    let tempC, tempF: Double?
    let isDay: Int?
    let condition: Condition?
    let windMph, windKph: Double?
    let windDegree: Double?
    let windDir: String?
    let pressureMB: Double?
    let pressureIn, precipMm, precipIn: Double?
    let humidity, cloud: Double?
    let feelslikeC, feelslikeF: Double?
    let visKM, visMiles, uv: Double?
    let gustMph, gustKph: Double?

    enum CodingKeys: String, CodingKey {
        case lastUpdatedEpoch = "last_updated_epoch"
        case lastUpdated = "last_updated"
        case tempC = "temp_c"
        case tempF = "temp_f"
        case isDay = "is_day"
        case condition
        case windMph = "wind_mph"
        case windKph = "wind_kph"
        case windDegree = "wind_degree"
        case windDir = "wind_dir"
        case pressureMB = "pressure_mb"
        case pressureIn = "pressure_in"
        case precipMm = "precip_mm"
        case precipIn = "precip_in"
        case humidity, cloud
        case feelslikeC = "feelslike_c"
        case feelslikeF = "feelslike_f"
        case visKM = "vis_km"
        case visMiles = "vis_miles"
        case uv
        case gustMph = "gust_mph"
        case gustKph = "gust_kph"
    }
}

// MARK: - Condition
struct Condition: Codable, Equatable {
    let text, icon: String?
    let code: Int?
}

// MARK: - Location
struct Location: Codable, Equatable {
    let id: Int?
    let url: String?
    let name, region, country: String?
    let lat, lon: Double?
    let tz_id: String?
    let localtime_epoch: Int?
    let localtime: String?
}
