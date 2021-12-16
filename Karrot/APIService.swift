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
    
    func getBookList(search: String) -> AnyPublisher<SearchBooks, Error> {
        return apiService.getSearch(query: search)
    }
}
extension String: Error {}

class APIService {
    private let urlSession: URLSession
    let url = "https://api.itbook.store/1.0/"
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    func getSearch(query: String) -> AnyPublisher<SearchBooks, Error> {
        guard let queryUrl = URL(string: url + "search/" + query) else { return Fail(error: "error1").eraseToAnyPublisher()}
        let a = urlSession.dataTaskPublisher(for: queryUrl)
            .mapError { _ -> Error in
                return "URL Error"
            }
            .map(\.data)
            .decode(type: SearchBooks.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
        
        return a
    }
}


//https://api.itbook.store/1.0/
struct SearchBooks: Codable {
    var total: String
    var error: String?
    var page: String?
    var books: [Book]
    
    
}


struct Book: Codable {
    var title: String?
    var subtitle: String?
    var isbn13: String?
    var price: String?
    var imageUrl: String?
    var url: String?
    enum CodingKeys: String, CodingKey {
        case title, subtitle, isbn13, price, url
        case imageUrl = "image"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try? values.decode(String.self, forKey: .title)
        self.subtitle = try? values.decode(String.self, forKey: .subtitle)
        self.isbn13 = try? values.decode(String.self, forKey: .isbn13)
        self.price = try? values.decode(String.self, forKey: .price)
        self.imageUrl = try? values.decode(String.self, forKey: .imageUrl)
        self.url = try? values.decode(String.self, forKey: .url)
    }
}
