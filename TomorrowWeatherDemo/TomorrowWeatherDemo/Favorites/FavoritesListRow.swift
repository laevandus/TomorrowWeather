//
//  FavoritesListRow.swift
//  TomorrowWeatherDemo
//
//  Created by Toomas Vahter on 13.12.2023.
//

import SwiftUI

struct FavoritesListRow: View {
    let weatherLocation: WeatherLocation

    // TODO: Wrap the current weather API and hook it up
    @State private var temperature: Double = 20.0

    var body: some View {
        HStack(alignment: .center) {
            Text(weatherLocation.city)
            Text(weatherLocation.countryName)
            Spacer()
            Text(String(temperature.formatted(.number.precision(.fractionLength(1)))))
                .font(.title)
            // TODO: unit!
        }
    }
}
