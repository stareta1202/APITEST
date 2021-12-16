//
//  ViewController.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/15.
//

import UIKit
import Combine

class ViewController: UIViewController {
    let urlSession: URLSession = .init(configuration: .default)
    lazy var apiService = APIService(urlSession: urlSession)
    private var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData()
        
    }

    func getData() {
        apiService.getSearch(query: "mongodb")
            .sink { error in
                let a = error
                print("1212error \(error )")
            } receiveValue: { books in
                print(282828, books)
            }
            .store(in: &subscription)
    }
}

