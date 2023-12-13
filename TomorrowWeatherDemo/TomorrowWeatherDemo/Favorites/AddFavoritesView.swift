//
//  AddFavoritesView.swift
//  TomorrowWeatherDemo
//
//  Created by Toomas Vahter on 13.12.2023.
//

import SwiftUI

struct AddFavoritesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    // TODO: filter out already favorited ones
    let locations: [WeatherLocation] = WeatherLocation.predefined

    @State private var selection: WeatherLocation.ID?

    var body: some View {
        NavigationStack {
            List(locations, selection: $selection) { location in
                Text(location.city)
                    .tag(location.id as WeatherLocation.ID?)
            }
            .navigationTitle("Locations")
            .toolbar(content: {
                Button("Close") { dismiss() }
            })
            .onChange(of: selection) {
                if let location = locations.first(where: { $0.id == selection }) {
                    modelContext.insert(location)
                }
                dismiss()
            }
        }
    }
}

#Preview {
    AddFavoritesView()
}
