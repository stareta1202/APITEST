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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
        bind()
    }
    
    private func initLayout() {
        view.backgroundColor = .white

        tableView.rowHeight = (UITableView.automaticDimension )
        view.add(tableView) { [unowned self] in
            $0.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
            $0.delegate = self
            $0.dataSource = self
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        }
        view.add(UIStackView()) { [unowned self] in
            $0.axis = .horizontal
            $0.distribution = .equalCentering
            $0.translatesAutoresizingMaskIntoConstraints = false

            $0.topAnchor.constraint(equalTo: self.tableView.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 64).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -64).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.addArranged(self.leftButton) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 4
                $0.backgroundColor = .orange.withAlphaComponent(0.2)
                $0.setTitle("이전 페이지", for: .normal)
                $0.setTitleColor(.black, for: .normal)
                $0.widthAnchor.constraint(equalToConstant: 96).isActive = true
            }
            
            $0.addArranged(pageLabel) {
                $0.textColor = .black
            }
            
            $0.addArranged(self.rightButton) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 4
                $0.backgroundColor = .orange.withAlphaComponent(0.2)
                $0.setTitle("다음 페이지", for: .normal)
                $0.setTitleColor(.black, for: .normal)
                $0.widthAnchor.constraint(equalToConstant: 96).isActive = true
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
    }
    
    private func bind() {
        self.viewModel.query$
            .filter({ $0.count == 0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] books in
                self?.books = []
                self?.tableView.reloadData()
            }.store(in: &subscription)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = DetailViewController.instantiate(with: books[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.query$.send(text)
        if viewModel.page > 1 { viewModel.page = 1 }
    }
}

extension UIView {
    var layout: AutoLayout {
        AutoLayout(view: self)
    }
}

class AutoLayout {
    var view: UIView
    private var innerLayout: Set<LayoutEnum> = []
    init(view: UIView) {
        self.view = view
    }
    
    var top: AutoLayout {
        self.innerLayout.insert(.top)
        return self
    }
    
    var leading: AutoLayout {
        self.innerLayout.insert(.leading)
        return self

    }
    
    var trailing: AutoLayout {
        self.innerLayout.insert(.trailing)
        return self

    }
    
    var bottom: AutoLayout {
        self.innerLayout.insert(.bottom)
        return self

    }
    
    
    func width(equalTo: CGFloat) -> AutoLayout {
        view.widthAnchor.constraint(equalToConstant: equalTo).isActive = true
        return self
    }
    
    func height(equalTo: CGFloat) -> AutoLayout {
        view.heightAnchor.constraint(equalToConstant: equalTo).isActive = true
        return self
    }
    
    func equalToSuperView(top: Bool = true, leading: Bool = true, trailling: Bool = true, bottom: Bool = true) {
        guard let superview = view.superview else { return }
        view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = top
        view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = leading
        view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = trailling
        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = bottom
    }
    
    func equalTo(_ other: UIView) {
        innerLayout.forEach { layout in
            switch layout {
            case .trailing:
                view.trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
            case .leading:
                view.trailingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
            case .top:
                view.topAnchor.constraint(equalTo: other.topAnchor).isActive = true
            case .bottom:
                view.bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
            }
        }
        
    }
    
    enum LayoutEnum {
        case top
        case leading
        case trailing
        case bottom
    }
}
