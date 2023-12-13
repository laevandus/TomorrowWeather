//
//  APIServices.swift
//
//
//  Created by Toomas Vahter on 13.12.2023.
//

import Foundation

enum APIServices {
    static var apiKey: String = ""
}

extension URLSession {
    static let apiServices: URLSession = URLSession(configuration: .ephemeral)
}
