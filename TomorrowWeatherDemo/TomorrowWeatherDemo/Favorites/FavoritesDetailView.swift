//
//  FavoritesDetailView.swift
//  TomorrowWeatherDemo
//
//  Created by Toomas Vahter on 13.12.2023.
//

import Charts
import SwiftUI
import TomorrowWeather

struct FavoritesDetailView: View {
    let weatherLocation: WeatherLocation
    @Environment(TomorrowWeather.self) var tomorrowWeather
    @State private var dailyWeather: [DayWeather] = []

    var body: some View {
        Form {
            Section {
                Text(weatherLocation.city)
                Text(weatherLocation.countryName)
            }
            if !dailyWeather.isEmpty {
                Section(header: Text("Temperatures")) {
                    Chart {
                        ForEach(dailyWeather) { weather in
                            LineMark(
                                x: .value("Time", weather.date),
                                y: .value("Low", weather.lowTemperature),
                                series: .value("Low", "l")
                            )
                            .foregroundStyle(.blue)
                            LineMark(
                                x: .value("Time", weather.date),
                                y: .value("High", weather.highTemperature),
                                series: .value("High", "h")
                            )
                            .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .task {
            do {
                dailyWeather = try await tomorrowWeather.weather(for: weatherLocation.location).dailyForecast
            }
            catch {
                // TODO: error
            }
        }
    }
}

//#Preview {
//    FavoritesDetailView()
//}
