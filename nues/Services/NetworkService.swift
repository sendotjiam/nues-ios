//
//  NetworkService.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation
import Alamofire
import RxSwift

protocol ApiClient {
    func request(
        _ path: String,
        _ method : HTTPMethod,
        _ parameters: [URLQueryItem]?,
        _ headers: HTTPHeaders?
    ) -> Observable<(HTTPURLResponse, Data)>
}

final class NetworkService : ApiClient {
     
    func request(
        _ path: String,
        _ method : HTTPMethod,
        _ parameters: [URLQueryItem]?,
        _ headers: HTTPHeaders?
    ) -> Observable<(HTTPURLResponse, Data)> {
        return Observable.create({ observer in
            let urlString = NetworkConstants.baseUrl + path + "?apiKey=" + NetworkConstants.apiKey
            guard let url = URL(string: urlString)!.addQueryParams(newParams: parameters ?? []) else {
                observer.onError(BaseErrors.anyError)
                return Disposables.create()
            }
            print(url)
            AF.request(
                url,
                method: method,
                parameters: nil,
                encoding: URLEncoding.default,
                headers: headers,
                interceptor: nil
            ).response { response in
                switch response.result {
                case .success(_) :
                    guard let httpResponse = response.response else {
                        observer.onError(BaseErrors.networkResponseError)
                        return
                    }
                    let statusCode = httpResponse.statusCode
                    guard let data = response.data else {
                        observer.onError(BaseErrors.emptyDataError)
                        return
                    }
                    guard (200...299).contains(statusCode) else {
                        observer.onError(BaseErrors.httpError(statusCode))
                        return
                    }
                    observer.onNext((httpResponse, data))
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(BaseErrors.anyError)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
    
}
