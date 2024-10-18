//
//  GetAllRecipesOperation.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Combine
import Foundation

struct GetAllRecipesOperation: ApiOperation {    
    var urlComponents: URLComponents {
        var components = baseUrlComponents
        components.path = "/recipes.json"
//        components.path = "/recipes-malformed.json"
//        components.path = "/recipes-empty.json"
        return components
    }
    
    var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func publisher() -> AnyPublisher<RecipeFeed, NetworkingError> {
        return makeRequest()
    }
    
    var headers: HTTPHeaders {
        return [
            "Content-Type" : "application/json",
            "Accept-Encoding" : "br"
//            "Accept": "application/json; charset=utf-8"
        ]
    }
    
}
