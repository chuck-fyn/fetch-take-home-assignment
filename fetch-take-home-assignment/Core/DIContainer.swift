//
//  DIContainer.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Foundation

final class DIContainer {
    
    let imageLoaderNetworkService: ImageLoaderNetworkServiceType
    let imageLoaderRepository: ImageLoaderRepositoryType
    let imageLoaderCache: ImageLoaderCacheType
    let recipeAPI: RecipeAPIType
    
    init() {
        self.recipeAPI = RecipeAPI()
        self.imageLoaderNetworkService = ImageLoaderNetworkService()
        self.imageLoaderCache = ImageLoaderCache()
        self.imageLoaderRepository = ImageLoaderRepository(networkService: imageLoaderNetworkService, imageCache: imageLoaderCache)
    }
    
}
