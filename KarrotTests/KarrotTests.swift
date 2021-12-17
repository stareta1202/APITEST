//
//  KarrotTests.swift
//  KarrotTests
//
//  Created by yjlee12 on 2021/12/18.
//

import XCTest
@testable import Karrot
import Combine

class KarrotTests: XCTestCase {
    var urlSession: URLSession = .init(configuration: .default)
    var apiService: APIService!
    var subscription = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        apiService = .init(urlSession: urlSession)

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        apiService = nil
    }
    
    func testApiInvalidURL() throws {
        var apiError: String?
        apiService.getSearch(query: "한", 1)
            .sink { error in
                switch error {
                case .failure(let _error):
                    apiError = _error.message
                case .finished:
                    break
                }
            } receiveValue: { searchBooks in
                print("success")
            }
            .store(in: &subscription)
        
        XCTAssertEqual(apiError, APIError.invalidURL.message)
    }
    
    func testApiInvalidPage() throws {
        var apiError: String?
        apiService.getSearch(query: "hello", -2)
            .sink {
                guard case .failure(let error) = $0 else { return }
                apiError = error.message
            } receiveValue: { searchBooks in
                print("success")
            }
            .store(in: &subscription)
        XCTAssertEqual(apiError, APIError.error("잘못된 페이지").message)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
