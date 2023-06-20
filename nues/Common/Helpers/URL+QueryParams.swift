//
//  URL+QueryParams.swift
//  nues
//
//  Created by Sendo Tjiam on 20/06/23.
//

import Foundation

extension URL {
    func addQueryParams(newParams: [URLQueryItem]) -> URL? {
        let urlComponents = NSURLComponents.init(url: self, resolvingAgainstBaseURL: false)
        guard urlComponents != nil else { return nil; }
        if (urlComponents?.queryItems == nil) {
            urlComponents!.queryItems = [];
        }
        urlComponents!.queryItems!.append(contentsOf: newParams);
        return urlComponents?.url;
    }
}
