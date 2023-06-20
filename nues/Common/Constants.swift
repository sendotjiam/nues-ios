//
//  Constants.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation

struct NetworkConstants {
    static let apiKey = "e52c905ea71b4b8faf41fec275c5c7f0"
    static let apiVersion = "/v2"
    static let baseUrl = "https://newsapi.org" + apiVersion
    
    static let getSources = "/sources"
    static let getArticles = "/everything"
    
    static let pageSize = "10"
}
