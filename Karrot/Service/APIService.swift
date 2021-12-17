//
//  APIService.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/16.
//

import Foundation
import Combine
import CoreMedia

class APIService {
    private let urlSession: URLSession
    let url = "https://api.itbook.store/1.0/"
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    func getSearch(query: String, _ page: Int = 1) -> AnyPublisher<SearchBooks, APIError> {
        if query == "" { return Empty<SearchBooks, APIError>(completeImmediately: true).eraseToAnyPublisher()}
        if page < 1 {
            return Fail(error: APIError.error("잘못된 페이지")).eraseToAnyPublisher()
        }
        guard let queryUrl = URL(string: url + "search/" + query + "/\(page)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: queryUrl)
            .mapError { _ -> APIError in
                return APIError.requestError
            }
            .map(\.data)
            .mapError({ error -> APIError in
                return APIError.responseError
            })
            .decode(type: SearchBooks.self, decoder: JSONDecoder())
            .mapError({ error -> APIError in
                return APIError.decodeError
            })
            .eraseToAnyPublisher()
    }
    
    func getISBN(isbn: String) -> AnyPublisher<ISBNBook, APIError> {
        guard let queryUrl = URL(string: url + "books/" + isbn) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        return urlSession.dataTaskPublisher(for: queryUrl)
            .mapError { _ -> APIError in
                return APIError.requestError
            }
            .map(\.data)
            .mapError({ error -> APIError in
                return APIError.responseError
            })
            .decode(type: ISBNBook.self, decoder: JSONDecoder())
            .mapError({ error -> APIError in
                return APIError.decodeError
            })
            .eraseToAnyPublisher()
    }
}
