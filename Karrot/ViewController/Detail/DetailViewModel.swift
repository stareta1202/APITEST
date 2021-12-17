//
//  DetailViewModel.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/17.
//

import Foundation
import Combine

class DetailViewModel: ObservableObject {
    private let urlSession: URLSession = .init(configuration: .default)
    private lazy var apiService = APIService(urlSession: urlSession)
    private var subscription = Set<AnyCancellable>()
    @Published var ISBNBook: ISBNBook?
    var error$ = CurrentValueSubject<APIError?, Never>(nil)

    init(isbn: String) {
        apiService.getISBN(isbn: isbn)
            .sink { [weak self] in
                guard case .failure(let error) = $0 else { return }
                self?.error$.send(error)
            } receiveValue: { [weak self] isbnBook in
                self?.ISBNBook = isbnBook
            }
            .store(in: &subscription)
    }
}
