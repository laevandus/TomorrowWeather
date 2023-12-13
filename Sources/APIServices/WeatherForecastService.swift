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
    let baseURL: URL
    let urlSession: URLSession

    package convenience init(baseURL: URL) {
        self.init(baseURL: baseURL, urlSession: .apiServices)
    }

    init(baseURL: URL, urlSession: URLSession) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    package func fetchForecast(for location: CLLocationCoordinate2D, timestep: Timestep = .daily) async throws -> Forecast {
        let url = baseURL.appending(path: "/v4/weather/forecast")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let endpoint = HTTPEndpoint<Forecast>(jsonResponseURL: url,
                                              query: [
                                                "apikey": APIServices.apiKey,
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
        let timelines: Timelines

        struct Timelines: Decodable {
            let daily: [Forecast]

            struct Forecast: Decodable {
                let time: Date
                let values: Values

                struct Values: Decodable {
                    let temperatureMin: Double
                    let temperatureMax: Double
                }
            }
        }
    }
}

private extension CLLocationCoordinate2D {
    var forecastQueryParameterValue: String {
        "\(latitude) \(longitude)"
    }
}
