//
//  WeatherForecastService.swift
//
//
//  Created by Toomas Vahter on 13.12.2023.
//

import CoreLocation
import Foundation
import Networking

package final class WeatherForecastService {
    let apiKey: String
    let baseURL: URL
    let urlSession: URLSession

    package convenience init(apiKey: String) {
        let baseURL = URL(string: "https://api.tomorrow.io")!
        self.init(baseURL: baseURL, apiKey: apiKey, urlSession: .apiServices)
    }

    init(baseURL: URL, apiKey: String, urlSession: URLSession) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    package func fetchForecast(for location: CLLocationCoordinate2D, timestep: Timestep = .daily) async throws -> Forecast {
        let url = baseURL.appending(path: "/v4/weather/forecast")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let endpoint = HTTPEndpoint<Forecast>(jsonResponseURL: url,
                                              query: [
                                                "apikey": apiKey,
                                                "location": location.forecastQueryParameterValue,
                                                "timesteps": timestep.rawValue,
                                              ],
                                              decoder: decoder)
        return try await urlSession.loadEndpoint(endpoint)
    }
}

extension WeatherForecastService {
    package enum Timestep: String {
        case daily = "1d"
//        case hourly = "1h"
    }
}

extension WeatherForecastService {
    package struct Forecast: Decodable {
        package let timelines: Timelines
        package let location: Location

        package struct Timelines: Decodable {
            package let daily: [Forecast]

            package struct Forecast: Decodable {
                package let time: Date
                package let values: Values

                package struct Values: Decodable {
                    package let temperatureMin: Double
                    package let temperatureMax: Double
                }
            }
        }

        package struct Location: Decodable {
            package let lat: Double
            package let lon: Double
        }
    }
}

private extension CLLocationCoordinate2D {
    var forecastQueryParameterValue: String {
        "\(latitude) \(longitude)"
    }
}
