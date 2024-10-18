//
//  RecipesViewModel.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Combine
import Foundation

final class RecipesViewModel {
    
    // TODO: - Add an error state to handle network failure and allow user to retry
    enum ViewState {
        case loading, loaded, failed
    }
    
    let recipeAPI: RecipeAPIType
    let imageLoaderRepository: ImageLoaderRepositoryType
    var disposeBag = Set<AnyCancellable>()
    
    @Published var recipes: [RecipeCellViewModel] = []
    @Published var viewState: ViewState = .loading

    init(recipeAPI: RecipeAPIType, imageLoaderRepository: ImageLoaderRepositoryType) {
        self.recipeAPI = recipeAPI
        self.imageLoaderRepository = imageLoaderRepository
    }
    
    func getRecipes() {
        recipeAPI.getAllRecipes().sink { completion in
            if case .failure(let error) = completion {
                debugPrint("Error loading recipe data: \(error)")
                self.viewState = .failed
            }
        } receiveValue: { [weak self] recipeFeed in
            guard let self = self else { return }
            self.viewState = .loading
            self.recipes = recipeFeed.recipes.map { RecipeCellViewModel(imageLoaderRepository: self.imageLoaderRepository, recipe: $0) }
            self.viewState = .loaded
        }
        .store(in: &disposeBag)
    }
    
    func sortByCuisine() {
        self.recipes = recipes.sortByCuisine()
    }
    
    func sortByName() {
        self.recipes = recipes.sortByName()
    }
}
