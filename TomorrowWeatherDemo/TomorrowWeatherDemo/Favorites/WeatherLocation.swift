//
//  WeatherLocation.swift
//  TomorrowWeatherDemo
//
//  Created by Toomas Vahter on 13.12.2023.
//

import CoreLocation
import Foundation
import SwiftData

@Model final class WeatherLocation {
    let city: String
    // TODO: consider replacing it with country code and asking for localized name through Locale
    let countryName: String
    let latitude: Double
    let longitude: Double

    init(city: String, countryName: String, latitude: Double, longitude: Double) {
        self.city = city
        self.countryName = countryName
        self.latitude = latitude
        self.longitude = longitude
    }

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension WeatherLocation: Identifiable {
    var id: String { "lat: \(location.latitude) lon:\(location.longitude)" }
}

extension WeatherLocation {
    static let predefined: [WeatherLocation] = [
        WeatherLocation(city: "London", countryName: "United Kingdom", latitude: 51.5074, longitude: -0.1278),
        WeatherLocation(city: "Berlin", countryName: "Germany", latitude: 52.5200, longitude: 13.4051),
        WeatherLocation(city: "Madrid", countryName: "Spain", latitude: 40.4168, longitude: -3.7038),
        WeatherLocation(city: "Kyiv", countryName: "Ukraine", latitude: 50.4501, longitude: 30.5234),
        WeatherLocation(city: "Rome", countryName: "Italy", latitude: 41.9028, longitude: 12.4964),
        WeatherLocation(city: "Paris", countryName: "France", latitude: 48.8566, longitude: 2.3522),
        WeatherLocation(city: "Bucharest", countryName: "Romania", latitude: 44.4268, longitude: 26.1025),
        WeatherLocation(city: "Vienna", countryName: "Austria", latitude: 48.2082, longitude: 16.3738),
        WeatherLocation(city: "Budapest", countryName: "Hungary", latitude: 47.4979, longitude: 19.0402)
    ]
}
