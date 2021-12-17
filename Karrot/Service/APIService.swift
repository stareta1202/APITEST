//
//  APIService.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/16.
//

import Foundation
import Combine
import CoreMedia

struct BookListModel {
    let apiService: APIService
    init(apiService: APIService){ self.apiService = apiService }
    
    func getBookList(search: String) -> AnyPublisher<SearchBooks, APIError> {
        return apiService.getSearch(query: search)
    }
}

class APIService {
    private let urlSession: URLSession
    let url = "https://api.itbook.store/1.0/"
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    func getSearch(query: String, _ page: Int? = nil) -> AnyPublisher<SearchBooks, APIError> {
        var stringPage: String = ""
        if let page = page { stringPage = "/\(page)" }

        guard let queryUrl = URL(string: url + "search/" + query + stringPage) else {
            return Fail(error: APIError.error("유효하지 않은 URL")).eraseToAnyPublisher()
        }
        return urlSession.dataTaskPublisher(for: queryUrl)
            .mapError { _ -> APIError in
                return APIError.requestError
            }
            .map(\.data)
            .decode(type: SearchBooks.self, decoder: JSONDecoder())
            .mapError({ error -> APIError in
                return APIError.responseError
            })
            .eraseToAnyPublisher()
    }
    
    func getISBN(isbn: Int) -> AnyPublisher<SearchBooks, APIError> {
        guard let queryUrl = URL(string: url + "book/" + String(isbn)) else {
            return Fail(error: APIError.error("유효하지 않은 URL")).eraseToAnyPublisher()
        }
        return urlSession.dataTaskPublisher(for: queryUrl)
            .mapError { _ -> APIError in
                return APIError.requestError
            }
            .map(\.data)
            .decode(type: SearchBooks.self, decoder: JSONDecoder())
            .mapError({ error -> APIError in
                return APIError.responseError
            })
            .eraseToAnyPublisher()
    }
}
