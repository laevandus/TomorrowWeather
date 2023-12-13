//
//  WeatherForecastServiceTests.swift
//  
//
//  Created by Toomas Vahter on 13.12.2023.
//

@testable import APIServices
import CoreLocation
import XCTest

final class WeatherForecastServiceTests: XCTestCase {
    let url = URL(string: "https://api.tomorrow.io")!

    func testParsingDailyForecastSuccessfully() async throws {
        let responseDataURL = try XCTUnwrap(Bundle.module.url(forResource: "ForecastDaily", withExtension: "json"))
        let responseData = try Data(contentsOf: responseDataURL)
        TestURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData, nil)
        }
        let service = WeatherForecastService(baseURL: url, urlSession: .testableSession())
        let result = try await service.fetchForecast(for: CLLocationCoordinate2D(latitude: 42.3478, longitude: -71.0466), timestep: .daily)
        XCTAssertEqual(result.timelines.daily.count, 6)
        XCTAssertEqual(result.timelines.daily[0].values.temperatureMin, 1.13, accuracy: 0.1)
        XCTAssertEqual(result.timelines.daily[0].values.temperatureMax, 6.13, accuracy: 0.1)
    }
}

extension URLSession {
    
}
