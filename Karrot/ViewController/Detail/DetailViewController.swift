//
//  DetailViewController.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/17.
//

import Foundation
import UIKit
import Combine
import PDFKit

class DetailViewController: UIViewController {
    private var subscription = Set<AnyCancellable>()
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var titleLabel = UILabel().custom(font: .preferredFont(forTextStyle: .title1))
    private var subtitleLabel = UILabel().custom(font: .preferredFont(forTextStyle: .subheadline))
    private var authorsLabel = UILabel()
    private var publisherLabel = UILabel()
    private var isbn10Label = UILabel()
    private var isbn13Label = UILabel()
    private var pagesLabel = UILabel()
    private var yearLabel = UILabel()
    private var ratingLabel = UILabel()
    private var descLabel = UILabel()
    private var priceLabel = UILabel()
    private var imageView = UIImageView()
    private var urlLabel = UILabel()
    private var pdfStackView = UIStackView()
    
    private var viewModel: DetailViewModel
    
    private var book: Book
    static func instantiate(with book: Book) -> DetailViewController {
        DetailViewController(book: book)
    }
    
    private init(book: Book) {
        self.book = book
        self.viewModel = .init(isbn: book.isbn13 ?? "")
        super.init(nibName: nil, bundle: nil)
        initView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
        return nil
    }
    
    private func initView() {
        view.backgroundColor = .white
        scrollView.alwaysBounceVertical = true
        view.add(scrollView) { [unowned self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,constant: 16).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        }
        scrollView.add(stackView) { [unowned self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .fill
            $0.spacing = 8
        }
        stackView.addArranged([
            imageView,
            titleLabel,
            subtitleLabel,
            authorsLabel,
            publisherLabel,
            isbn10Label,
            isbn13Label,
            pagesLabel,
            yearLabel,
            ratingLabel,
            descLabel,
            priceLabel,
            urlLabel,
            pdfStackView,
        ])
    }
    
    private func bind() {
        viewModel.$ISBNBook
            .receive(on: DispatchQueue.main)
            .sink { [weak self] book in
                guard let self = self else { return }
                guard let book = book else { return }
                self.titleLabel.text = book.title
                self.subtitleLabel.text = book.subtitle
                self.authorsLabel.text = "author : \(book.authors ?? "")"
                self.publisherLabel.text = "pubslihser : \(book.publisher ?? "")"
                self.isbn10Label.text = "ISBN10 : \(book.isbn10 ?? "")"
                self.isbn13Label.text = "ISBN13 : \(book.isbn13 ?? "")"
                self.pagesLabel.text = "pages: \(book.pages ?? "")"
                self.yearLabel.text = "year: \(book.year ?? "")"
                self.ratingLabel.text = "rating : \(book.rating ?? "")"
                self.priceLabel.text = "price: \(book.price ?? "")"
                self.imageView.setImageUrl(book.imageUrl)
            }
            .store(in: &subscription)
        
        viewModel.$ISBNBook.map(\.?.pdf)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pdfs in
                guard let pdfs = pdfs else { return }
                guard let self = self else { return }
                for pdf in pdfs {
                    self.pdfStackView.axis = .vertical
                    self.pdfStackView.addArranged(UILabel()) {
                        $0.text = pdf.key
                        $0.translatesAutoresizingMaskIntoConstraints = false
                        $0.heightAnchor.constraint(equalToConstant: 32).isActive = true
                    }
                    self.pdfStackView.addArranged(PDFView()) {
                        $0.translatesAutoresizingMaskIntoConstraints = false
                        $0.leadingAnchor.constraint(equalTo: self.pdfStackView.leadingAnchor).isActive = true
                        $0.trailingAnchor.constraint(equalTo: self.pdfStackView.trailingAnchor).isActive = true
                        $0.heightAnchor.constraint(equalToConstant: 400).isActive = true
                        $0.autoScales = true
                        $0.displayMode = .singlePageContinuous
                        $0.displayDirection = .vertical
                        guard let url = URL(string: pdf.value) else { return }
                        $0.document = PDFDocument(url: url)
                    }
                }
            }
            .store(in: &subscription)
    }
}
