//
//  APIServices.swift
//
//
//  Created by Toomas Vahter on 13.12.2023.
//

import Foundation

extension URLSession {
    static let apiServices: URLSession = URLSession(configuration: .ephemeral)
}
