//
//  APIOperation.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Combine
import Foundation

public protocol ApiOperation {
    associatedtype ReturnType
    var urlComponents: URLComponents { get }
    var session: URLSession { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var body: Data? { get }
    func publisher() -> AnyPublisher<ReturnType, NetworkingError>
}

extension ApiOperation {
    
    public func request() throws -> URLRequest {
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    public var baseUrlComponents: URLComponents  {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "d3jbb8n5wk0qxi.cloudfront.net"
        return components
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var body: Data? {
        return nil
    }
    
    var headers: HTTPHeaders {
        return [:]
    }
}

extension ApiOperation {
    
    func makeRequest<T>() -> AnyPublisher<T, NetworkingError> where T: Decodable {
        do {
            let request = try self.request()
            return session.dataTaskPublisher(for: request)
                .verifyStatusCodes()
                .handleJsonResponse()
                .eraseToAnyPublisher()
        } catch {
            return Fail<T, NetworkingError>(error: NetworkingError.invalidRequest).eraseToAnyPublisher()
        }
    }
}

extension Publisher where Output == Data {
    func handleJsonResponse<T>() -> AnyPublisher<T, NetworkingError> where T: Decodable {

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            if let date = DateFormatter.iso8601.date(from: dateStr) {
                return date
            }
            throw NetworkingError.custom("Invalid date")
        })
        
        return decode(type: T.self, decoder: decoder)
            .mapError {
                return $0 as? NetworkingError ?? NetworkingError.unknown(error: nil)
            }
            .eraseToAnyPublisher()
    }
}

extension URLSession.DataTaskPublisher {
    func verifyStatusCodes() -> AnyPublisher<Data, Error> {
        return tryMap { output in
            guard let response = output.response as? HTTPURLResponse else {
                throw NetworkingError.invalidResponse
            }
            let code = response.statusCode
            
            switch code {
            case 200..<300:
                return output.data
            case 401:
                throw NetworkingError.authorizationFailure
            case 404:
                throw NetworkingError.resourceNotFound
            case 400...499:
                throw NetworkingError.client(code: code)
            case 500...599:
                throw NetworkingError.server(code: code)
            default:
                throw NetworkingError.invalidResponse
            }
        }
        .eraseToAnyPublisher()
    }
}

public typealias HTTPHeaders = [String: String]
