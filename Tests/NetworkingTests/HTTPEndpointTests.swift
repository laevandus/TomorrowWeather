//
//  HTTPEndpointTests.swift
//  
//
//  Created by Toomas Vahter on 13.12.2023.
//

import XCTest
@testable import Networking

final class HTTPEndpointTests: XCTestCase {
    override func tearDownWithError() throws {
        TestURLProtocol.loadingHandler = nil
    }

    // MARK: - Success

    func testParsingJSONResponseSuccessfully() async throws {
        let expected = TestResponsePayload(name: "My Name")
        TestURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, try? JSONEncoder().encode(expected), nil)
        }
        let url = try XCTUnwrap(URL(string: "https://www.example.com"))
        let endpoint = HTTPEndpoint<TestResponsePayload>(jsonResponseURL: url)
        let urlSession = URLSession.testableSession()
        let result = try await urlSession.loadEndpoint(endpoint)
        XCTAssertEqual(result, expected)
    }

    // MARK: - Expected Failures

    func testUnexpectedStatusCode() async throws {
        TestURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, nil, nil)
        }
        let url = try XCTUnwrap(URL(string: "https://www.example.com"))
        let endpoint = HTTPEndpoint<TestResponsePayload>(jsonResponseURL: url)
        let urlSession = URLSession.testableSession()
        do {
            _ = try await urlSession.loadEndpoint(endpoint)
        }
        catch {
            if let endpointError = error as? HTTPEndpointError {
                switch endpointError {
                case .unexpectedHTTPStatusCode(let statusCode):
                    XCTAssertEqual(statusCode, 404)
                default:
                    XCTFail("Expected unexpectedHTTPStatusCode but received \(endpointError)")
                }
            }
            else {
                throw error
            }
        }
    }
}

// MARK: -

private struct TestResponsePayload: Codable, Equatable {
    let name: String
}
