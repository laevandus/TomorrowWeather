//
//  HTTPEndpoint.swift
//
//
//  Created by Toomas Vahter on 13.12.2023.
//

import Foundation

/// HTTPEndpoint provides a convenient way for creating URLRequest for various use-cases.
package struct HTTPEndpoint<ResponsePayload> {
    let request: () throws -> URLRequest
    let responseParser: (Data?, URLResponse?) throws -> ResponsePayload
    let retries: Int
    let expectedStatusCode: (Int) -> Bool

    init(url: URL,
         headers: [String: String] = [:],
         query: [String: String] = [:],
         method: Method,
         body: Data? = nil,
         contentType: ContentType? = nil,
         accept: ContentType? = nil,
         timeout: TimeInterval = 15,
         retries: Int = 1,
         expectedStatusCode: @escaping (Int) -> Bool = expect200,
         responseParser: @escaping (Data?, URLResponse?) throws -> ResponsePayload) {
        request = {
            var endpointURL = url

            if !query.isEmpty {
                let additionalQueryItems = query.map({ URLQueryItem(name: $0.key, value: $0.value) })
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                let existingQueryItems = components?.queryItems ?? []
                components?.queryItems = existingQueryItems + additionalQueryItems
                if let url = components?.url {
                    endpointURL = url
                }
                else {
                    throw HTTPEndpointError.invalidURLRequest
                }
            }

            var request = URLRequest(url: endpointURL, timeoutInterval: timeout)
            if let contentType {
                request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
            }
            if let accept {
                request.setValue(accept.rawValue, forHTTPHeaderField: "Accept")
            }
            headers.forEach { name, value in
                request.setValue(value, forHTTPHeaderField: name)
            }
            request.httpMethod = method.rawValue
            request.httpBody = body
            return request
        }
        self.responseParser = responseParser
        self.expectedStatusCode = expectedStatusCode
        self.retries = retries
    }
}

// MARK: Interacting with JSON HTTP Endpoints

extension HTTPEndpoint where ResponsePayload: Decodable {
    /// Represents a HTTP endpoint which returns JSON data.
    /// - Parameters:
    ///   - url: The base URL of the endpoint.
    ///   - headers: Additional HTTP headers ("Accept" header is set by default).
    ///   - query: Additional query parameters.
    ///   - method: The HTTP method.
    ///   - timeout: The request timeout (defaults to 15 seconds).
    ///   - retries: The number of times to try to load the request on a connection failure.
    ///   - expectedStatusCode: HTTP status code validator (default expects 200 only).
    ///   - decoder: The JSON decoder for parsing the JSON data.
    package init(jsonResponseURL url: URL,
                headers: [String: String] = [:],
                query: [String: String] = [:],
                method: Method = .get,
                timeout: TimeInterval = 15,
                retries: Int = 1,
                expectedStatusCode: @escaping (Int) -> Bool = expect200,
                decoder: JSONDecoder = JSONDecoder()) {
        self.init(url: url, headers: headers, query: query, method: method, body: nil, contentType: nil, accept: .json, timeout: timeout, retries: retries, expectedStatusCode: expectedStatusCode, responseParser: { data, _ in
            guard let data, !data.isEmpty else { throw HTTPEndpointError.emptyData }
            return try decoder.decode(ResponsePayload.self, from: data)
        })
    }
}

// MARK: -

extension HTTPEndpoint {
    /// HTTP methods.
    package enum Method: String {
        /// The HTTP method for GET requests.
        case get = "GET"
    }

    /// HTTP content types.
    package enum ContentType: String {
        /// The HTTP content type for JSON
        case json = "application/json"
    }

    /// Expects that server returns HTTP status code 200.
    package static func expect200(_ code: Int) -> Bool {
        return code == 200
    }
}

/// The error describing HTTP endpoint loading failures.
package enum HTTPEndpointError: Error {
    /// Connection failed with underlying error.
    case connection(Error)
    /// Expected response data but no data was returned.
    case emptyData
    /// Failed to create a URLRequest
    case invalidURLRequest
    /// Failed to parse response data.
    case responseParsing(Error)
    /// Expected HTTPURLResponse but non-HTTP response was received.
    case unknownURLResponse
    /// Unexpected HTTP status code was received.
    case unexpectedHTTPStatusCode(Int)
    /// The request succeeded but server failed to compose a response data (e.g. missing or invalid request parameters).
    case responsePayloadFailure
}
