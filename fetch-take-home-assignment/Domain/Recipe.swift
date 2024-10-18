//
//  Recipe.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Foundation

public struct Recipe: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case cuisine
        case name
        case photo_url_large
        case photo_url_small
        case source_url
        case uuid
        case youtube_url
    }
    
    var cuisine: String
    var name: String
    var photo_url_large: String?
    var photo_url_small: String?
    var source_url: String?
    var uuid: String
    var youtube_url: String?
}

extension Recipe: Equatable, Hashable {}

struct RecipeFeed: Decodable {    
    var recipes: [Recipe]
}
