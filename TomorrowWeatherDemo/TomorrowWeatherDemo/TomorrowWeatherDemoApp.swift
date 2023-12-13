//
//  TomorrowWeatherDemoApp.swift
//  TomorrowWeatherDemo
//
//  Created by Toomas Vahter on 13.12.2023.
//

import SwiftData
import SwiftUI
import TomorrowWeather

@main
struct TomorrowWeatherDemoApp: App {
    // TODO: Move it to a separate file
    var modelContainer: ModelContainer = {
        let schema = Schema([WeatherLocation.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } 
        catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    // TODO: Move it to dependency container
    let tomorrowWeather = TomorrowWeather(apiKey: "")
    #error("Add API key")

    var body: some Scene {
        WindowGroup {
            FavoritesListView()
        }
        .modelContainer(modelContainer)
        .environment(tomorrowWeather)
    }
}
