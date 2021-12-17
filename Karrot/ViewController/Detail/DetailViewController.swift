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
            $0.snp.makeConstraints { [unowned self] (make) in
                make.top.bottom.equalToSuperview()
                make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).inset(16)
                make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(16)
            }
        }
        scrollView.add(stackView) { [unowned self] in
            $0.snp.makeConstraints { [unowned self] make in
                make.top.bottom.equalToSuperview()
                make.leading.trailing.equalToSuperview()
                make.width.equalTo(self.scrollView)
            }
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
                        $0.snp.makeConstraints { make in
                            make.height.equalTo(32)
                        }
                    }
                    self.pdfStackView.addArranged(PDFView()) {
                        $0.snp.makeConstraints { make in
                            make.leading.trailing.equalToSuperview().inset(32)
                            make.height.equalTo(320)
                        }
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
