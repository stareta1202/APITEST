//
//  ViewController.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/15.
//

import UIKit
import AddThen
import Combine
import MapKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var subscription = Set<AnyCancellable>()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var books: [Book] = []
    private var viewModel: MainViewModel = .init()
    private var leftButton = UIButton(type: .system)
    private var pageLabel = UILabel()
    private var rightButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        initSerachController()
        initLayout()
        setupConfiguration()
        bind()
    }
    
    private func initLayout() {
        view.backgroundColor = .white
        tableView.rowHeight = (UITableView.automaticDimension )
        view.add(tableView)
        view.add(UIStackView()) { [unowned self] in
            $0.addArranged(self.leftButton)
            $0.addArranged(pageLabel) { $0.textColor = .black }
            $0.addArranged(self.rightButton)
            
            $0.axis = .horizontal
            $0.distribution = .equalCentering
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.topAnchor.constraint(equalTo: self.tableView.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 64).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -64).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
    }
    
    private func setupConfiguration(){
        initTableView()
        initButtons()
    }
    
    private func initTableView() {
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
    }
    
    private func initButtons() {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.layer.masksToBounds = true
        leftButton.layer.cornerRadius = 4
        leftButton.backgroundColor = .orange.withAlphaComponent(0.2)
        leftButton.setTitle("이전 페이지", for: .normal)
        leftButton.setTitleColor(.black, for: .normal)
        leftButton.widthAnchor.constraint(equalToConstant: 96).isActive = true
        
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.layer.masksToBounds = true
        rightButton.layer.cornerRadius = 4
        rightButton.backgroundColor = .orange.withAlphaComponent(0.2)
        rightButton.setTitle("다음 페이지", for: .normal)
        rightButton.setTitleColor(.black, for: .normal)
        rightButton.widthAnchor.constraint(equalToConstant: 96).isActive = true
    }
    
    private func initSerachController() {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchBar.placeholder = "책 검색하기"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.isSearchResultsButtonSelected = true
    }
    
    private func bind() {
        viewModel.query$
            .filter({ $0.count == 0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] books in
                self?.books = []
                self?.tableView.reloadData()
            }.store(in: &subscription)
        
        viewModel.$books
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bookList in
                self?.books = bookList
                self?.tableView.reloadData()
            }
            .store(in: &subscription)
        
        leftButton.addAction(UIAction(handler: {[weak self] _ in
            guard let self = self else { return }
            guard self.viewModel.page > 1 else { return }
            self.viewModel.page -= 1
        }), for: .touchUpInside)
        
        rightButton.addAction(UIAction(handler: {[weak self] _ in
            self?.viewModel.page += 1
        }), for: .touchUpInside)
        
        Publishers
            .CombineLatest(
                viewModel.$page,
                viewModel.$maxPage
            )
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currentPage, maxPage in
                self.leftButton.isEnabled = currentPage == 1 ? false : true
                self.rightButton.isEnabled = currentPage == maxPage ? false : true
                self.pageLabel.text = "\(currentPage) / \(maxPage)"
            }.store(in: &subscription)
        
        viewModel.error$.sink { [weak self] error in
            guard let error = error else { return }
            self?.showAlert(error.message)
        }.store(in: &subscription)
    }
}

extension MainViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return MainTableViewCell(
            style: .default,
            reuseIdentifier: MainTableViewCell.identifier,
            book: books[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = DetailViewController.instantiate(with: books[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.query$.send(text)
        if viewModel.page > 1 { viewModel.page = 1 }
    }
}

extension MainViewController {
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "오류가 발생했어요", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "다시 입력하기", style: .default) {[weak self] _ in
            guard let self = self else { return }
            self.searchController.searchBar.text = ""
            self.viewModel.getData()
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
