//
//  CategoryListRouter.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit

protocol CategoryListRouterProtocol: AnyObject {
    func pushToSourceListScreen(with category: CategoryModel, using navController: UINavigationController?)
}

final class CategoryListRouter : CategoryListRouterProtocol {
    static func createModule() -> CategoryListViewController {
        let router = CategoryListRouter()
        let vc = CategoryListViewController()
        let interactor = CategoryListInteractor()
        let presenter = CategoryListPresenter(view: vc, router: router, interactor: interactor)
        vc.presenter = presenter
        return vc
    }
    
    func pushToSourceListScreen(with category: CategoryModel, using navController: UINavigationController?) {
        let vc = SourceListRouter.createModule(with: category, using: navController)
        navController?.pushViewController(vc, animated: true)
    }
}

