//
//  SourceListViewController.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol SourceListViewProtocol: AnyObject {
    func reloadView()
    func showError(_ error: BaseErrors)
}

final class SourceListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
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
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var errorView = {
        let view = ErrorView()
        view.isHidden = true
        return view
    }()
    var presenter: SourceListPresenterProtocol = SourceListPresenter(view: nil, router: nil, interactor: nil)
    
    private let bag = DisposeBag()
    
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

extension SourceListViewController {
    func setupViews() {
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
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
    
    func setupBindings() {
        searchBar.rx.text.orEmpty
            .asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] keyword in
                self?.presenter.search(with: keyword)
            }).disposed(by: bag)
        searchBar.rx.cancelButtonClicked
            .subscribe({ [weak self] _ in
                self?.searchBar.text = ""
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
    
    func registerCells() {
        tableView.register(SourceTableViewCell.self, forCellReuseIdentifier: SourceTableViewCell.identifier)
    }
    
    @objc func refresh() {
        presenter.loadData()
    }
    
    func setupNav() {
        let category = presenter.getCurrentCategory()
        title = category.isEmpty ? "News Sources" : category.capitalized
    }
}

extension SourceListViewController: SourceListViewProtocol {
    func reloadView() {
        tableView.isHidden = false
        errorView.isHidden = true
        tableView.performBatchUpdates { [weak self] in
            guard let self = self else { return }
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let indexSet = NSIndexSet(indexesIn: range) as IndexSet
            self.tableView.reloadSections(indexSet, with: .automatic)
            self.refreshControl.endRefreshing()
        }
    }
    func showError(_ error: BaseErrors) {
        tableView.isHidden = true
        errorView.isHidden = false
        errorView.error = error
        errorView.delegate = self
    }
}

extension SourceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getItemCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SourceTableViewCell.identifier, for: indexPath) as? SourceTableViewCell
        cell?.data = presenter.getDataByIndex(indexPath.row)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let source = presenter.getDataByIndex(indexPath.row) else {
            return
        }
        presenter.didSelect(source, with: self.navigationController)
    }
}

extension SourceListViewController: ErrorViewDelegate {
    func didTapReload() {
        presenter.loadData()
    }
}
