//
//  ViewController.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/15.
//

import UIKit
import AddThen
import SnapKit
import Combine
import MapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var subscription = Set<AnyCancellable>()
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var books: [Book] = []
    private var viewModel: MainViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        initSerachController()
        initLayout()
        bind()
    }
    
    private func initLayout() {
        view.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        view.add(tableView) {
            $0.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
            $0.delegate = self
            $0.dataSource = self
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func initSerachController() {
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchBar.placeholder = "search by title"
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    private func bind() {
        self.viewModel.$books
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bookList in
                self?.books = bookList
                self?.tableView.reloadData()
            }
            .store(in: &subscription)
    }


}

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return MainTableViewCell(
            style: .default,
            reuseIdentifier: MainTableViewCell.identifier,
            book: books[indexPath.row])
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text.count > 1 {
            viewModel.getData(query: text)
        }
    }
}

class MainViewModel: ObservableObject {
    private let urlSession: URLSession = .init(configuration: .default)
    private lazy var apiService = APIService(urlSession: urlSession)
    private var subscription = Set<AnyCancellable>()
    @Published var books: [Book] = []
    
    init() {
    }
    
    func getData(query: String, _ page: Int? = nil) {
        print("string: \(query)")
        apiService.getSearch(query: query, page)
            .map({ $0.books })
            .sink { error in
                switch error {
                case .failure(let error):
                    print("error: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] books in
                print("🤔 \(books)")
                self?.books = books
            }.store(in: &subscription)
    }
}
