//
//  BookModel.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/17.
//

import Foundation

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
