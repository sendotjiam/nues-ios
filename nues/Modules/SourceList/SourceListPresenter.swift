//
//  SourceListPresenter.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation
import RxSwift

protocol SourceListPresenterProtocol: AnyObject {
    func loadData()
    func search(with keyword: String)
    func getDataByIndex(_ index: Int) -> SourceModel?
    func getCurrentCategory() -> String
    func didSelect(_ source: SourceModel, with navController: UINavigationController?)
    var getItemCount: Int { get }
    var getSectionCount: Int { get }
}

final class SourceListPresenter {
    private weak var view: SourceListViewProtocol?
    private var router: SourceListRouterProtocol?
    private var interactor: SourceListInteractorProtocol?
    private var sourceList : [SourceModel]?
    private var shownList = [SourceModel]()
    private let bag = DisposeBag()
    
    var category : CategoryModel?
    
    init(view: SourceListViewProtocol?, router: SourceListRouterProtocol?, interactor: SourceListInteractorProtocol?) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

extension SourceListPresenter: SourceListPresenterProtocol {
    func loadData() {
        guard let category = category else {
            return
        }
        interactor?.fetchSources(with: category).subscribe({ [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next(let model):
                self.sourceList = model.sources
                self.shownList = model.sources
                self.view?.reloadView()
            case .error(let error):
                guard let error = error as? BaseErrors else { return }
                self.view?.showError(error)
            case .completed: break
            }
        }).disposed(by: bag)
    }
    
    func search(with keyword: String) {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let sourceList = sourceList else {
            self.view?.showError(BaseErrors.emptyDataError)
            return
        }
        if query.isEmpty {
            shownList = sourceList
        } else {
            shownList = sourceList.filter({ source in
                source.name.lowercased().contains(query)
            })
        }
        view?.reloadView()
    }
    
    func didSelect(_ source: SourceModel, with navController: UINavigationController?) {
        router?.pushToArticleListScreen(with: source, using: navController)
    }
    
    func getDataByIndex(_ index: Int) -> SourceModel? {
        shownList[index]
    }
    
    func getCurrentCategory() -> String {
        return category?.rawValue ?? ""
    }
    
    var getItemCount: Int {
        shownList.count
    }
    
    var getSectionCount: Int {
        1
    }
}
