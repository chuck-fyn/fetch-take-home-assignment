//
//  RecipeCellViewModel.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import UIKit

class RecipeCellViewModel {
    
    private let imageLoaderRepository: ImageLoaderRepositoryType
    let recipe: Recipe
    
    @Published public var image = UIImage.photoPlaceholder

    init(imageLoaderRepository: ImageLoaderRepositoryType, recipe: Recipe) {
        self.imageLoaderRepository = imageLoaderRepository
        self.recipe = recipe
    }
    
    func loadImageData() {
        guard let url = recipe.photo_url_small else { return }
        
        Task {
            do {
                image = try await imageLoaderRepository.loadImage(urlString: url)
            } catch {
                // TODO: - Unless the error is cancelled, add an option to retry
                debugPrint("Error loading image from repository: \(error)")
            }
        }
    }
    
    func cancelLoading() async {
        guard let url = recipe.photo_url_small else { return }
        await imageLoaderRepository.cancelImageLoadIfNeeded(urlString: url)
    }
}

extension RecipeCellViewModel: Equatable, Hashable {
    static func == (lhs: RecipeCellViewModel, rhs: RecipeCellViewModel) -> Bool {
        lhs.recipe == rhs.recipe
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(recipe)
    }
}

extension Collection where Element == RecipeCellViewModel {
    func sortByCuisine() -> [RecipeCellViewModel] {
        return self.sorted(by: { $0.recipe.cuisine <  $1.recipe.cuisine })
    }
    
    func sortByName() -> [RecipeCellViewModel] {
        return self.sorted(by: { $0.recipe.name <  $1.recipe.name })
    }
}
