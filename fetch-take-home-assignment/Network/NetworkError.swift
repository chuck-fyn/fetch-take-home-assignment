//
//  NetworkError.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Foundation

public enum NetworkingError: Error, LocalizedError, Equatable {
    case authorizationFailure
    case invalidRequest
    case client(code: Int)
    case server(code: Int)
    case invalidResponse
    case resourceNotFound
    case unknown(error: Error?)
    case custom(String)
    
    public static func == (lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        return lhs.errorDescription == rhs.errorDescription
    }
}
