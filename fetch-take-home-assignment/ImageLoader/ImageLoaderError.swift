//
//  ImageLoaderError.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Foundation

public enum ImageLoaderError: Error {
    case invalidURL
    case serverError
    case decodingError
}
