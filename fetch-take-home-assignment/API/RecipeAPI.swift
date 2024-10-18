//
//  RecipeAPI.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Combine
import Foundation

protocol RecipeAPIType {
    func getAllRecipes() -> AnyPublisher<RecipeFeed, NetworkingError>
}

class RecipeAPI: RecipeAPIType {
    private var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getAllRecipes() -> AnyPublisher<RecipeFeed, NetworkingError> {
        return GetAllRecipesOperation(session: session).publisher()
    }
}
