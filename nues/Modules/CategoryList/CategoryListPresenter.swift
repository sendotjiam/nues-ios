//
//  CategoryListPresenter.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit
import RxSwift

protocol CategoryListPresenterProtocol: AnyObject {
    func loadData()
    func didSelect(_ category: CategoryModel, with navController: UINavigationController?)
    var getItemCount: Int { get }
    var getSectionCount: Int { get }
    func getDataByIndex(_ index: Int) -> CategoryModel?
}

final class CategoryListPresenter {
    
    private weak var view: CategoryListViewProtocol?
    private var router: CategoryListRouterProtocol?
    private var interactor: CategoryListInteractorProtocol?
    private var categoryList : [CategoryModel]?
    private var sourceList : [SourceModel]?
    private let bag = DisposeBag()
    
    init(view: CategoryListViewProtocol?, router: CategoryListRouterProtocol?, interactor: CategoryListInteractorProtocol?) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

extension CategoryListPresenter: CategoryListPresenterProtocol {
    
    func didSelect(_ category: CategoryModel, with navController: UINavigationController?) {
        router?.pushToSourceListScreen(with: category, using: navController)
    }
    
    func loadData() {
        fetchCategoryList()
    }
    
    func fetchCategoryList() {
        interactor?.fetchSources().subscribe({ [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next(let model):
                self.sourceList = model.sources
                self.categoryList = Array(Set(model.sources.map({ source in
                    return source.category
                })))
                self.view?.reloadView()
            case .error(let error):
                self.sourceList = nil
                self.categoryList = nil
                guard let error = error as? BaseErrors else {
                    self.view?.showError(.anyError)
                    return
                }
                self.view?.showError(error)
            case .completed:
                break
            }
        }).disposed(by: bag)
    }
    
    var getItemCount: Int {
        categoryList?.count ?? 0
    }
    
    var getSectionCount: Int {
        1
    }
    
    func getDataByIndex(_ index: Int) -> CategoryModel? {
        categoryList?[index]
    }
}
