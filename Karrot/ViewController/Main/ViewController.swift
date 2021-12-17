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
    
    private var leftButton = UIButton()
    private var pageLabel = UILabel()
    private var rightButton = UIButton()
    
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

        tableView.rowHeight = (UITableView.automaticDimension )
        view.add(tableView) {
            $0.backgroundColor = .white
            $0.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
            $0.delegate = self
            $0.dataSource = self
            $0.snp.makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(80)
            }
        }
        view.add(UIStackView()) { [unowned self] in
            $0.axis = .horizontal
            $0.distribution = .equalCentering
            $0.snp.makeConstraints { make in
                make.top.equalTo(self.tableView.snp.bottom)
                make.leading.trailing.equalToSuperview().inset(64)
                make.height.equalTo(40)
            }
            $0.addArranged(self.leftButton) {
                $0.setTitle("이전 페이지", for: .normal)
                $0.setTitleColor(.black, for: .normal)
                $0.snp.makeConstraints { make in
                    make.width.equalTo(96)
                }
            }
            $0.addArranged(pageLabel) {
                $0.textColor = .black
            }
            $0.addArranged(self.rightButton) {
                $0.setTitle("다음 페이지", for: .normal)
                $0.setTitleColor(.black, for: .normal)
                $0.backgroundColor = .red
                $0.snp.makeConstraints { make in
                    make.width.equalTo(96)
                }
            }
        }
    }
    
    private func initSerachController() {
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchBar.placeholder = "책 검색하기"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.isSearchResultsButtonSelected = true
        searchController.searchBar.showsCancelButton = false
    }
    
    private func bind() {
        self.viewModel.$books
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
            viewModel.query$.send(text)
            if viewModel.page > 1 { viewModel.page = 1 }
        }
    }
}

