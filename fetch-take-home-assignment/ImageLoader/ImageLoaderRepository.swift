//
//  ImageLoaderRepository.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import UIKit

public protocol ImageLoaderRepositoryType: AnyObject {
    func loadImage(urlString: String) async throws -> UIImage
    func cancelImageLoadIfNeeded(urlString: String) async
}

public class ImageLoaderRepository: ImageLoaderRepositoryType {
    private let networkService: ImageLoaderNetworkServiceType
    private let imageCache: ImageLoaderCacheType
    
    init(networkService: ImageLoaderNetworkServiceType, imageCache: ImageLoaderCacheType) {
        self.networkService = networkService
        self.imageCache = imageCache
    }
    
    public func loadImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ImageLoaderError.invalidURL
        }
            
        if let image = await imageCache.image(for: url) {
            return image
        }
        
        let image = try await networkService.downloadImage(url: url)
        await imageCache.insert(image, for: url)
        return image
    }
    
    public func cancelImageLoadIfNeeded(urlString: String) async {
        await networkService.cancelLoading(urlString: urlString)
    }
    
}
