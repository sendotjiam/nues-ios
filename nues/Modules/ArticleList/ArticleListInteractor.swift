//
//  ArticleListInteractor.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation
import RxSwift

protocol ArticleListInteractorProtocol: AnyObject {
    func fetchArticles(for page: Int, with source: SourceModel, keyword: String) -> Observable<ArticleResponseModel>
}

final class ArticleListInteractor: ArticleListInteractorProtocol {
    private let service: ApiClient
    
    init(service: ApiClient = NetworkService()) {
        self.service = service
    }
    
    func fetchArticles(for page: Int, with source: SourceModel, keyword: String) -> Observable<ArticleResponseModel> {
        var params : [URLQueryItem] = [
            URLQueryItem(name: "q", value: keyword.lowercased()),
            URLQueryItem(name: "sources", value: source.id),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        if keyword.isEmpty {
            params.append(URLQueryItem(name: "pageSize", value: NetworkConstants.pageSize))
        }
        return service
            .request(NetworkConstants.getArticles, .get, params, nil)
            .map({ (_, data) in
                do {
                    let sources = try JSONDecoder().decode(ArticleResponseModel.self, from: data)
                    return sources
                } catch {
                    print(error)
                    throw BaseErrors.decodeError
                }
            })
    }
}
