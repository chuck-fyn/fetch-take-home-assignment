//
//  RecipeAPITests.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import XCTest
import Combine
import Foundation
@testable import fetch_take_home_assignment

class RecipeAPITests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []

    func testGetAllRecipesSuccess() {
        let expectation = XCTestExpectation(description: "Fetch all recipes")
        
        // Mock JSON data for success case
        let jsonData = """
        {
            "recipes": []
        }
        """.data(using: .utf8)

        // Setup the mock URL session
        let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
        let data = jsonData
        let response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolMock.mockURLs = [url: (nil, data, response)]
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: sessionConfiguration)
        
        let recipeAPI = RecipeAPI(session: mockSession)

        recipeAPI.getAllRecipes()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but got failure with error: \(error)")
                }
            }, receiveValue: { recipeFeed in
                // Validate the returned RecipeFeed
                XCTAssertNotNil(recipeFeed)
                XCTAssertEqual(recipeFeed.recipes.count, 0)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetAllRecipesFailure() {
        let expectation = XCTestExpectation(description: "Handle failure response")
        
        // Setup the mock URL session
        let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
        let data = Data()
        let response = HTTPURLResponse(url: url!, statusCode: 404, httpVersion: nil, headerFields: nil)
        URLProtocolMock.mockURLs = [url: (nil, data, response)]
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: sessionConfiguration)
                
        let recipeAPI = RecipeAPI(session: mockSession)

        recipeAPI.getAllRecipes()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Check if the error matches expected
                    XCTAssertEqual(error, .resourceNotFound)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but got a value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}

class URLProtocolMock: URLProtocol {
    static var mockURLs = [URL?: (error: Error?, data: Data?, response: HTTPURLResponse?)]()

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let url = request.url {
            if let (error, data, response) = URLProtocolMock.mockURLs[url] {
                
                // We have a mock response specified so return it.
                if let responseStrong = response {
                    self.client?.urlProtocol(self, didReceive: responseStrong, cacheStoragePolicy: .notAllowed)
                }
                
                // We have mocked data specified so return it.
                if let dataStrong = data {
                    self.client?.urlProtocol(self, didLoad: dataStrong)
                }
                
                // We have a mocked error so return it.
                if let errorStrong = error {
                    self.client?.urlProtocol(self, didFailWithError: errorStrong)
                }
            }
        }

        // Send the signal that we are done returning our mock response
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}



