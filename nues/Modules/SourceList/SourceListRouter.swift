//
//  SourceListRouter.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit

protocol SourceListRouterProtocol: AnyObject {
    func pushToArticleListScreen(with source: SourceModel, using navController: UINavigationController?)
}

final class SourceListRouter: SourceListRouterProtocol {
    static func createModule(with category: CategoryModel, using navController: UINavigationController?) -> SourceListViewController {
        let router = SourceListRouter()
        let vc = SourceListViewController()
        let interactor = SourceListInteractor()
        let presenter = SourceListPresenter(view: vc, router: router, interactor: interactor)
        presenter.category = category
        vc.presenter = presenter
        return vc
    }
    
    func pushToArticleListScreen(with source: SourceModel, using navController: UINavigationController?) {
        let vc = ArticleListRouter.createModule(with: source, using: navController)
        navController?.pushViewController(vc, animated: true)
    }
    
}
