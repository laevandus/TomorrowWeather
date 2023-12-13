//
//  TomorrowWeather.swift
//
//
//  Created by Toomas Vahter on 13.12.2023.
//

import APIServices
import CoreLocation
import Foundation
import Persistence

/// Provides an interface for obtaining weather data.
@Observable public final class TomorrowWeather {
    private let service: WeatherForecastService
    private let store: DailyWeatherStore

    /// Creates a weather object for retrieving weather information.
    public init(apiKey: String) {
        self.service = WeatherForecastService(apiKey: apiKey)
        self.store = DailyWeatherStore()
    }

    /// Returns the weather forecast for the requested location.
    public func weather(for location: CLLocationCoordinate2D) async throws -> Weather {
        // TODO: Revisit this but keep it simple for now by trying to fetch, if fails, try offline.
        // TODO: Review if it makes sense to cache on the SDK level or leave the caching for apps instead
        do {
            let forecastPayload = try await service.fetchForecast(for: location)
            await store.storeForecast(forecastPayload, location: location)
            return Weather(data: forecastPayload)
        }
        catch {
            // Since fetching failed, try hitting the local store
            if let forecast = await store.retrieveForecast(for: location) {
                return Weather(data: forecast)
            }
            else {
                throw error
            }
        }
    }
}

// MARK: -

/// A model representing the aggregate weather data.
public struct Weather {
    /// The location of the weather forecast.
    public let location: CLLocationCoordinate2D
    /// A list of daily forecasts.
    public let dailyForecast: [DayWeather]
}

extension Weather: Identifiable {
    public var id: String { "lat: \(location.latitude) lon:\(location.longitude)" }
}

/// A structure that represents the weather conditions for the day.
public struct DayWeather {
    /// The start time of the day weather.
    public let date: Date
    /// The overnight low temperature.
    public let lowTemperature: Double
    /// The daytime high temperature.
    public let highTemperature: Double
}

extension DayWeather: Identifiable {
    public var id: Date { date }
}

// MARK: - Mapping

extension Weather {
    init(data: WeatherForecastService.Forecast) {
        location = CLLocationCoordinate2D(latitude: data.location.lat,
                                          longitude: data.location.lon)
        dailyForecast = data.timelines.daily.map({ data in
            DayWeather(date: data.time,
                       lowTemperature: data.values.temperatureMin,
                       highTemperature: data.values.temperatureMax)
        })
    }

    init(data: DailyForecast) {
        location = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        dailyForecast = data.dailyValues.map({ data in
            DayWeather(date: data.date,
                       lowTemperature: data.temperatureMin,
                       highTemperature: data.temperatureMax)
        })
    }
}

extension WeatherForecastService.Forecast: DailyForecast {
    package var latitude: Double {
        location.lat
    }
    
    package var longitude: Double {
        location.lon
    }
    
    package var dailyValues: [DailyValue] {
        struct Item: DailyValue {
            let temperatureMax: Double
            let temperatureMin: Double
            let date: Date
        }

        return timelines.daily.map { data in
            Item(temperatureMax: data.values.temperatureMax, temperatureMin: data.values.temperatureMin, date: data.time)
        }
    }
}
