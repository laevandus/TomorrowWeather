//
//  FavoritesListView.swift
//  TomorrowWeatherDemo
//
//  Created by Toomas Vahter on 13.12.2023.
//

import TomorrowWeather
import SwiftData
import SwiftUI

struct FavoritesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\WeatherLocation.city)]) private var locations: [WeatherLocation]
    @State private var isPresentingAddSheet = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(locations) { location in
                    NavigationLink {
                        FavoritesDetailView(weatherLocation: location)
                    } label: {
                        FavoritesListRow(weatherLocation: location)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddFavoritesView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        isPresentingAddSheet = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(locations[index])
            }
        }
    }
}

#Preview {
    FavoritesListView()
        .modelContainer(for: WeatherLocation.self, inMemory: true)
}
