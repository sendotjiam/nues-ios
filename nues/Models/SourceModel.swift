//
//  SourceModel.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation

struct SourcesResponseModel: Codable {
    let status: String
    let sources: [SourceModel]
}

struct SourceModel: Codable {
    let id, name, description: String
    let url: String
    let category: CategoryModel
    let language, country: String
}

enum CategoryModel: String, Codable {
    case business = "business"
    case entertainment = "entertainment"
    case general = "general"
    case health = "health"
    case science = "science"
    case sports = "sports"
    case technology = "technology"
}


