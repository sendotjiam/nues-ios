//
//  ArticleListViewController.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

protocol ArticleListViewProtocol: AnyObject {
    func showError(_ error: BaseErrors)
    func reloadView()
    func showWebView(with url: URL)
}

final class ArticleListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    private lazy var errorView = {
        let view = ErrorView()
        view.isHidden = true
        return view
    }()

    var presenter: ArticleListPresenterProtocol = ArticleListPresenter(view: nil, router: nil, interactor: nil)
    
    private let bag = DisposeBag()
    
    private var keyword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
        presenter.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
    }
}

extension ArticleListViewController {
    private func setupViews() {
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(errorView)
        registerCells()
        searchBar.snp.makeConstraints({ make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        tableView.snp.makeConstraints({ make in
            make.top.equalTo(searchBar.snp_bottomMargin).offset(8)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        })
        errorView.snp.makeConstraints({ make in
            make.top.equalTo(searchBar.snp_bottomMargin).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        })
    }
    
    private func registerCells() {
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.identifier)
    }
    
    private func setupBindings() {
        searchBar.rx.text.orEmpty
            .asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] keyword in
                self?.keyword = keyword
                self?.presenter.search(with: keyword)
            }).disposed(by: bag)
        searchBar.rx.cancelButtonClicked
            .subscribe({ [weak self] _ in
                self?.searchBar.text = ""
                self?.keyword = ""
            }).disposed(by: bag)
        tableView.rx.didScroll.subscribe({ [weak self] _ in
            guard let self = self else { return }
            let offSetY = self.tableView.contentOffset.y
            let contentHeight = self.tableView.contentSize.height
            
            if offSetY > (contentHeight - self.tableView.frame.size.height - 100) {
                if !self.presenter.isRequesting && self.keyword.isEmpty {
                    self.presenter.loadMore(isSearch: !self.keyword.isEmpty)
                }
            }
        }).disposed(by: bag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func onKeyboardWillHideNotification(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    @objc private func onKeyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardSize = userInfo.cgRectValue.size
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - view.safeAreaInsets.bottom, right: 0)
    }
    
    func setupNav() {
        let source = presenter.getCurrentSource()
        title = source.isEmpty ? "Articles" : source.capitalized
    }
}

extension ArticleListViewController: ArticleListViewProtocol {
    func reloadView() {
        tableView.isHidden = false
        errorView.isHidden = true
        tableView.performBatchUpdates { [weak self] in
            guard let self = self else { return }
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let indexSet = NSIndexSet(indexesIn: range) as IndexSet
            self.tableView.reloadSections(indexSet, with: .automatic)
        }
    }
    
    func showError(_ error: BaseErrors) {
        tableView.isHidden = true
        errorView.isHidden = false
        errorView.error = error
        errorView.delegate = self
    }
    
    func showWebView(with url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.getSectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return presenter.getItemCount
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier) as? ArticleTableViewCell
            let data = presenter.getDataByIndex(indexPath.row)
            cell?.data = data
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifier, for: indexPath) as? LoadingTableViewCell
            if self.keyword.isEmpty {
                cell?.activityIndicator.startAnimating()
            } else {
                cell?.isHidden = true
            }
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let article = presenter.getDataByIndex(indexPath.row) else {
            return
        }
        presenter.didSelect(article)
    }
}

extension ArticleListViewController: ErrorViewDelegate {
    func didTapReload() {
        presenter.loadData()
    }
}
