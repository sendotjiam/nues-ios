//
//  BaseErrors.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation

enum BaseErrors: Error {
    case anyError
    case networkResponseError
    case emptyDataError
    case httpError(_ code: Int)
    case decodeError
}
