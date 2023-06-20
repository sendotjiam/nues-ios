//
//  ArticleListRouter.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit

protocol ArticleListRouterProtocol: AnyObject {
    
}

final class ArticleListRouter : ArticleListRouterProtocol{
    static func createModule(with source: SourceModel, using navController: UINavigationController?) -> ArticleListViewController {
        let router =  ArticleListRouter()
        let vc =  ArticleListViewController()
        let interactor =  ArticleListInteractor()
        let presenter = ArticleListPresenter(view: vc, router: router, interactor: interactor)
        presenter.source = source
        vc.presenter = presenter
        return vc
    }
    
    
}
