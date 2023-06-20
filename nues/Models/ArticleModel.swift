//
//  ArticleModel.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation

struct ArticleResponseModel: Codable {
    let status: String
    let totalResults: Int
    let articles: [ArticleModel]
}

struct ArticleModel: Codable {
    let source: SourceInArticleModel
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String
}


struct SourceInArticleModel: Codable {
    let id: String?
    let name: String
}
