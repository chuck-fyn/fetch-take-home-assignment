//
//  ImageLoaderNetworkService.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import UIKit

public protocol ImageLoaderNetworkServiceType: AnyObject {
    func downloadImage(url: URL) async throws -> UIImage
    func cancelLoading(urlString: String) async
}

/// I am using 'Actor' here to protect the mutable state of the running requests dictionary
/// Because this is being used in a UICollecitonView and users can scroll fast there is a chance for race conditions
/// Alternatives to this would be use a serial dispatch queue, semaphore or lock
public actor ImageLoaderNetworkService: ImageLoaderNetworkServiceType {
    private var runningRequests = [String: Task<UIImage, Error>]()
    private let session = URLSession.shared
    
    public func downloadImage(url: URL) async throws -> UIImage {
        let task = Task {
            defer { runningRequests[url.absoluteString] = nil }
            let (data, response) = try await session.data(for: URLRequest(url: url))
            
            guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else { throw ImageLoaderError.serverError }
            guard let image = UIImage(data: data) else { throw ImageLoaderError.decodingError }
            return image
        }
        
        runningRequests[url.absoluteString] = task
        return try await task.value
    }
    
    public func cancelLoading(urlString: String) {
        runningRequests[urlString]?.cancel()
        runningRequests[urlString] = nil
    }
}
