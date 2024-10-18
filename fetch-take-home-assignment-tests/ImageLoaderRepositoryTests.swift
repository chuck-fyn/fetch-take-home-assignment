//
//  ImageLoaderRepositoryTests.swift
//  fetch-take-home-assignment-tests
//
//  Created by Charles Prutting on 10/16/24.
//

import XCTest
@testable import fetch_take_home_assignment

class ImageLoaderRepositoryTests: XCTestCase {
    
    class MockNetworkService: ImageLoaderNetworkServiceType {
        var shouldReturnError = false
        var downloadedImage: UIImage?
        
        func downloadImage(url: URL) async throws -> UIImage {
            if shouldReturnError {
                throw ImageLoaderError.serverError
            }
            return downloadedImage ?? UIImage()
        }
        
        func cancelLoading(urlString: String) async {}
    }
    
    class MockImageCache: ImageLoaderCacheType {
        var cachedImage: UIImage?
        
        func image(for url: URL) async -> UIImage? {
            return cachedImage
        }
        
        func insert(_ image: UIImage?, for url: URL) async {
            cachedImage = image
        }
        
        func remove(for url: URL) async {}
        
        func removeAll() async {}
    }
    
    var repository: ImageLoaderRepository!
    var mockNetworkService: MockNetworkService!
    var mockImageCache: MockImageCache!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockImageCache = MockImageCache()
        repository = ImageLoaderRepository(networkService: mockNetworkService, imageCache: mockImageCache)
    }
    
    override func tearDown() {
        repository = nil
        mockNetworkService = nil
        mockImageCache = nil
        super.tearDown()
    }
    
    func testLoadImage_CachesImage() async {
        // Given
        let urlString = "http://example.com/image.png"
        let expectedImage = UIImage()
        mockNetworkService.downloadedImage = expectedImage
        
        // When
        let image = try? await repository.loadImage(urlString: urlString)
        
        // Then
        XCTAssertNotNil(image)
        XCTAssertEqual(image, expectedImage)
        XCTAssertEqual(mockImageCache.cachedImage, expectedImage)
    }
    
    func testLoadImage_ReturnsCachedImage() async {
        // Given
        let urlString = "http://example.com/image.png"
        let cachedImage = UIImage()
        mockImageCache.cachedImage = cachedImage
        
        // When
        let image = try? await repository.loadImage(urlString: urlString)
        
        // Then
        XCTAssertNotNil(image)
        XCTAssertEqual(image, cachedImage)
    }
    
    func testLoadImage_InvalidURL() async {
        // Given
        let invalidURLString = ""
        
        // When
        do {
            _ = try await repository.loadImage(urlString: invalidURLString)
            XCTFail("Expected error not thrown")
        } catch let error as ImageLoaderError {
            XCTAssertEqual(error, ImageLoaderError.invalidURL)
        } catch {
            XCTFail("Expected ImageLoaderError but got \(error)")
        }
    }
    
    func testLoadImage_NetworkError() async {
        // Given
        let urlString = "http://example.com/image.png"
        mockNetworkService.shouldReturnError = true
        
        // When
        do {
            _ = try await repository.loadImage(urlString: urlString)
            XCTFail("Expected error not thrown")
        } catch let error as ImageLoaderError {
            XCTAssertEqual(error, ImageLoaderError.serverError)
        } catch {
            XCTFail("Expected ImageLoaderError but got \(error)")
        }
    }
}

