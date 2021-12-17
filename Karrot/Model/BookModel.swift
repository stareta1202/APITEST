//
//  BookModel.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/17.
//

import Foundation

struct ISBNBook: Codable {
    var error: String?
    var title: String?
    var subtitle: String?
    var authors: String?
    var publisher: String?
    var isbn10: String?
    var isbn13: String?
    var pages: String?
    var year: String?
    var rating: String?
    var desc: String?
    var price: String?
    var imageUrl: String?
    var url: String?
    var pdf: [String: String]?
    enum CodingKeys: String, CodingKey {
        case error,
             title,
             subtitle,
             authors,
             publisher,
             isbn10,
             isbn13,
             pages,
             year,
             rating,
             desc,
             price,
             url,
             pdf
        case imageUrl = "image"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.error = try? values.decode(String.self, forKey: .error)
        self.title = try? values.decode(String.self, forKey: .title)
        self.subtitle = try? values.decode(String.self, forKey: .subtitle)
        self.authors = try? values.decode(String.self, forKey: .authors)
        self.publisher = try? values.decode(String.self, forKey: .publisher)
        self.isbn10 = try? values.decode(String.self, forKey: .isbn10)
        self.isbn13 = try? values.decode(String.self, forKey: .isbn13)
        self.pages = try? values.decode(String.self, forKey: .pages)
        self.year = try? values.decode(String.self, forKey: .year)
        self.rating = try? values.decode(String.self, forKey: .rating)
        self.desc = try? values.decode(String.self, forKey: .desc)
        self.price = try? values.decode(String.self, forKey: .price)
        self.imageUrl = try? values.decode(String.self, forKey: .imageUrl)
        self.url = try? values.decode(String.self, forKey: .url)
        self.pdf = try? values.decode(Dictionary.self, forKey: .pdf)
    }
}

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
