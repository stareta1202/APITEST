//
//  MainViewModel.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/17.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    private let urlSession: URLSession = .init(configuration: .default)
    private lazy var apiService = APIService(urlSession: urlSession)
    private var subscription = Set<AnyCancellable>()
    var query$ = CurrentValueSubject<String, Never>("")
    @Published var books: [Book] = []
    @Published var page: Int = 1
    @Published var maxPage: Int = 1
    
    init() {
        getData()
    }
    
    func getData() {
        Publishers.CombineLatest(
            query$.eraseToAnyPublisher(),
            $page.eraseToAnyPublisher())
            .flatMap { [weak self] query, page -> AnyPublisher<SearchBooks, APIError> in
                guard let self = self else {
                    return Fail(error: APIError.error("모종의 이유")).eraseToAnyPublisher()
                }
                return self.apiService.getSearch(query: query, page)
            }
            .sink { [weak self] error in
                guard let self = self else { return }
                switch error {
                case .failure(let error):
                    print("errorrrrr i s : \(error)")
                    self.query$.send("")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] searchBooks in
                guard let self = self else { return }
                if let total = Int(searchBooks.total) {
                    self.maxPage = (total / 10) + 1
                }
                self.books = searchBooks.books
            }
            .store(in: &subscription)
    }
}
