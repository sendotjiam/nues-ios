//
//  ArticleListPresenter.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import Foundation
import RxSwift

protocol ArticleListPresenterProtocol: AnyObject {
    func loadData()
    func didSelect(_ article: ArticleModel)
    func loadMore(isSearch: Bool)
    func getDataByIndex(_ index: Int) -> ArticleModel?
    func getCurrentSource() -> String
    func search(with keyword: String)
    var isRequesting: Bool { get }
    var getItemCount: Int { get }
    var getSectionCount: Int { get }
}

final class ArticleListPresenter {
    private weak var view: ArticleListViewProtocol?
    private var router: ArticleListRouterProtocol?
    private var interactor: ArticleListInteractorProtocol?
    private var sourceList : [ArticleModel]?
    private let bag = DisposeBag()
    
    var source : SourceModel?
    var isRequesting: Bool = false
    
    private var shownList = [ArticleModel]()
    private var searchedList = [ArticleModel]()
    private var articleList = [ArticleModel]()
    
    private var searchedPage = 1
    private var currentPage = 1
    
    private var keyword = ""
    
    init(view: ArticleListViewProtocol?, router: ArticleListRouterProtocol?, interactor: ArticleListInteractorProtocol?) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    func fetchArticles() {
        guard let source = source else { return }
        let page = self.keyword.isEmpty ? self.currentPage : self.searchedPage
        interactor?.fetchArticles(for: page, with: source, keyword: keyword).subscribe({ [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next(let model):
                if self.keyword.isEmpty {
                    self.articleList.append(contentsOf: model.articles)
                    self.shownList = self.articleList
                } else {
                    self.searchedList.append(contentsOf: model.articles)
                    self.shownList = self.searchedList
                }
                self.view?.reloadView()
            case .error(let error):
                guard let error = error as? BaseErrors else {
                     return
                }
                self.view?.showError(error)
            case .completed: break
            }
            self.isRequesting = false
        }).disposed(by: bag)
    }
}

extension ArticleListPresenter: ArticleListPresenterProtocol {
    
    func didSelect(_ article: ArticleModel) {
        guard let url = URL(string: article.url) else {
            return
        }
        view?.showWebView(with: url)
    }
    
    func getCurrentSource() -> String {
        source?.name ?? ""
    }
    
    func loadData() {
        isRequesting = true
        fetchArticles()
    }
    
    func loadMore(isSearch: Bool) {
        isRequesting = true
        if isSearch {
            searchedPage += 1
        } else { currentPage += 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
            self?.fetchArticles()
        })
    }
    
    func search(with keyword: String) {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.keyword = keyword
        if query.isEmpty {
            shownList = articleList
            searchedPage = 1
        } else {
            fetchArticles()
        }
        view?.reloadView()
    }
    
    func getDataByIndex(_ index: Int) -> ArticleModel? {
        shownList[index]
    }
    
    var getItemCount: Int {
        shownList.count
    }
    
    var getSectionCount: Int {
        2
    }
    
}
