//
//  DailyWeatherStore.swift
//
//
//  Created by Toomas Vahter on 13.12.2023.
//

import CoreData
import CoreLocation
import Foundation
import os

package protocol DailyForecast {
    var latitude: Double { get }
    var longitude: Double { get }
    var dailyValues: [DailyValue] { get }
}

package protocol DailyValue {
    var temperatureMax: Double { get }
    var temperatureMin: Double { get }
    var date: Date { get }
}

package final class DailyWeatherStore {
    package init() {}

    private var container: PersistenceConteiner?

    // FIXME: Setup should be moved to somewhere else
    func preparedContainer() async -> PersistenceConteiner {
        if let container {
            return container
        }
        else {
            container = PersistenceConteiner()
            do {
                try await container?.load()
            }
            catch {
                Logger().debug("Failed to load persistence container with error: \(error.localizedDescription)")
            }
            return container!
        }
    }

    package func retrieveForecast(for location: CLLocationCoordinate2D) async -> DailyForecast? {
        let container = await preparedContainer()
        return retrieveForecast(for: location, in: container.viewContext)
    }

    func retrieveForecast(for location: CLLocationCoordinate2D, in context: NSManagedObjectContext) -> CDDailyForecast? {
        let fetchRequest: NSFetchRequest<CDDailyForecast> = CDDailyForecast.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", location.latitude, location.longitude)
        do {
            return try context.fetch(fetchRequest).first
        }
        catch {
            Logger().debug("Failed to retrieve forecast for: \(location.latitude) \(location.longitude)")
            return nil
        }
    }

    package func storeForecast(_ forecast: DailyForecast, location: CLLocationCoordinate2D) async {
        // FIXME: Replace with upserting later
        let context = await preparedContainer().newBackgroundContext()
        if let forecast = retrieveForecast(for: location, in: context) {
            context.delete(forecast)
        }

        let cdForecast = CDDailyForecast(context: context)
        cdForecast.latitude = location.latitude
        cdForecast.longitude = location.longitude
        let values = forecast.dailyValues
            .map({ data in
                let value = CDDailyValue(context: context)
                value.timestamp = data.date
                value.temperatureMin = data.temperatureMin
                value.temperatureMax = data.temperatureMax
                return value
            })
        cdForecast.addToValues(NSSet(array: values))
        do {
            try context.save()
        }
        catch {
            Logger().debug("Failed to store forecast with error: \(error.localizedDescription)")
        }
    }
}

extension CDDailyForecast: DailyForecast {
    package var dailyValues: [DailyValue] {
        guard let setValues = values as? Set<CDDailyValue> else { return [] }
        return setValues.sorted(using: KeyPathComparator(\CDDailyValue.date))
    }
}

extension CDDailyValue: DailyValue {
    package var date: Date {
        timestamp ?? .now
    }
}
