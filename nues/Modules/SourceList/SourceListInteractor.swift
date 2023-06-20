//
//  SourceListInteractor.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation
import RxSwift

protocol SourceListInteractorProtocol: AnyObject {
    func fetchSources(with category: CategoryModel) -> Observable<SourcesResponseModel>
}

final class SourceListInteractor: SourceListInteractorProtocol {
    private let service: ApiClient
    
    init(service: ApiClient = NetworkService()) {
        self.service = service
    }
    
    func fetchSources(with category: CategoryModel) -> Observable<SourcesResponseModel> {
        let param = URLQueryItem(name: "category", value: category.rawValue)
        return service
            .request(NetworkConstants.getSources, .get, [param], nil)
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
