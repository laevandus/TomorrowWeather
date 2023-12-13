//
//  HTTPEndpoint+URLSession.swift
//
//
//  Created by Toomas Vahter on 13.12.2023.
//

import Foundation

package protocol URLSessionEndpointLoading {
    func loadEndpoint<ResponsePayload>(_ endpoint: HTTPEndpoint<ResponsePayload>) async throws -> ResponsePayload
}

extension URLSession: URLSessionEndpointLoading {
    /// Loads a HTTP endpoint and returns the response payload.
    /// - Parameter endpoint: The endpoint to load.
    /// - Throws: Always returns a ``HTTPEndpointError`` if a failure occures.
    /// - Returns: The model object created by parsing the response data.
    package func loadEndpoint<ResponsePayload>(_ endpoint: HTTPEndpoint<ResponsePayload>) async throws -> ResponsePayload {
        let request: URLRequest
        do {
            request = try endpoint.request()
        }
        catch {
            throw HTTPEndpointError.invalidURLRequest
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await Task.retried(times: endpoint.retries) {
                try await self.data(for: request)
            }.value
        }
        catch {
            throw HTTPEndpointError.connection(error)
        }

        guard let httpURLResponse = response as? HTTPURLResponse else { throw HTTPEndpointError.unknownURLResponse }
        guard endpoint.expectedStatusCode(httpURLResponse.statusCode) else { throw HTTPEndpointError.unexpectedHTTPStatusCode(httpURLResponse.statusCode) }
        do {
            return try endpoint.responseParser(data, httpURLResponse)
        }
        catch {
            throw HTTPEndpointError.responseParsing(error)
        }
    }
}

extension Task {
    static func retried(times: Int, backoff: TimeInterval = 1.0, priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) -> Task where Failure == Error {
        Task(priority: priority) {
            for attempt in 0..<times {
                do {
                    return try await operation()
                }
                catch {
                    let exponentialDelay = UInt64(backoff * pow(2.0, Double(attempt)) * 1_000_000_000)
                    try await Task<Never, Never>.sleep(nanoseconds: exponentialDelay)
                    continue
                }
            }
            return try await operation()
        }
    }
}
