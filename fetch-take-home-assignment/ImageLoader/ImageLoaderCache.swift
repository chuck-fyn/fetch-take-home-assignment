//
//  ImageLoaderCache.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/17/24.
//

import UIKit

public protocol ImageLoaderCacheType: AnyObject {
    func image(for url: URL) async -> UIImage?
    func insert(_ image: UIImage?, for url: URL) async
    func remove(for url: URL) async
    func removeAll() async
}

/// I am using 'Actor' here to protect the mutable state of the cache
/// Because this is being used in a UICollecitonView and users can scroll fast there is a chance for race conditions
/// Alternatives to this would be use a serial dispatch queue, semaphore or lock
public actor ImageLoaderCache: ImageLoaderCacheType {
    
    private let cache: NSCache<NSURL, UIImage>

    public init(countLimit: Int = 100) {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = countLimit
        cache.totalCostLimit = 20_000_000
        
        self.cache = cache
    }

    public func image(for url: URL) -> UIImage? {
        guard let url = NSURL(string: url.absoluteString) else { return nil }
        return cache.object(forKey: url)
    }

    public func insert(_ image: UIImage?, for url: URL) {
        guard let url = NSURL(string: url.absoluteString), let image = image else {
            return remove(for: url)
        }
        cache.setObject(image, forKey: url)
    }

    public func remove(for url: URL) {
        guard let url = NSURL(string: url.absoluteString) else { return }
        cache.removeObject(forKey: url)
    }

    public func removeAll() {
        cache.removeAllObjects()
    }
}
