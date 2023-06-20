//
//  CategoryListInteractor.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation
import RxSwift

protocol CategoryListInteractorProtocol: AnyObject {
    func filter(sources : [SourceModel], by category: CategoryModel) -> [SourceModel]
    func fetchSources() -> Observable<SourcesResponseModel>
}

final class CategoryListInteractor: CategoryListInteractorProtocol {
    private let service: ApiClient
    
    init(service: ApiClient = NetworkService()) {
        self.service = service
    }
    
    func filter(sources : [SourceModel], by category: CategoryModel) -> [SourceModel] {
        return sources.filter({ $0.category == category })
    }
    
    func fetchSources() -> Observable<SourcesResponseModel> {
        return service
            .request(NetworkConstants.getSources, .get, nil, nil)
            .map({ (_, data) in
                do {
                    let sources = try JSONDecoder().decode(SourcesResponseModel.self, from: data)
                    return sources
                } catch {
                    throw BaseErrors.decodeError
                }
            })
    }
}
