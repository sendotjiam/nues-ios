//
//  UIViewController+Alert.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit

extension UIViewController {
    func createSimpleAlert(_ title : String,
                           _ message: String,
                           _ actionTitle : String,
                           _ callback : ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        if let callback = callback {
            let action = UIAlertAction(
                title: actionTitle,
                style: .cancel,
                handler: callback
            )
            alert.addAction(action)
        } else {
            let action = UIAlertAction(
                title: actionTitle,
                style: .cancel,
                handler: nil
            )
            alert.addAction(action)
        }
        return alert
    }
}
