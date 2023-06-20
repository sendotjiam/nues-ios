//
//  CategoryListViewController.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit
import SnapKit

protocol CategoryListViewProtocol: AnyObject {
    func reloadView()
    func showError(_ error: BaseErrors)
}

final class CategoryListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // Only use for initial loading
    private lazy var activityIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        return indicator
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
    var presenter: CategoryListPresenterProtocol = CategoryListPresenter(view: nil, router: nil, interactor: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
    }
    
}

extension CategoryListViewController : CategoryListViewProtocol {
    func setupViews() {
        activityIndicator.startAnimating()
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
        view.addSubview(activityIndicator)
        view.addSubview(tableView)
        view.addSubview(errorView)
        registerCells()
        activityIndicator.snp.makeConstraints({ make in
            make.center.equalToSuperview()
        })
        tableView.snp.makeConstraints({ make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
        })
        errorView.snp.makeConstraints({ make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        })
    }
    
    func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func reloadView() {
        tableView.isHidden = false
        errorView.isHidden = true
        tableView.performBatchUpdates { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
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
    
    func setupNav() {
        title = "Categories"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    @objc func refresh() {
        presenter.loadData()
    }
}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getItemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = presenter.getDataByIndex(indexPath.row)?.rawValue.capitalized
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let category = presenter.getDataByIndex(indexPath.row) else {
            return
        }
        presenter.didSelect(category, with: self.navigationController)
    }
}

extension CategoryListViewController: ErrorViewDelegate {
    func didTapReload() {
        presenter.loadData()
    }
}
