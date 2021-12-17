//
//  SearchBooks.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/18.
//

import Foundation

struct SearchBooks: Codable {
    var total: String
    var error: String?
    var page: String?
    var books: [Book]
}
