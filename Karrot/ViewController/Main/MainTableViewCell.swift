//
//  MainTableViewCell.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/17.
//

import Foundation
import UIKit

class MainTableViewCell: UITableViewCell {
    static let identifier = "MainTableViewCell"
    private var leftImageView = UIImageView()
    private var book: Book
    private var mainStackView = UIStackView()
    private var titleStackView = UIStackView()
    private var titleLabel = UILabel()
    private var subtitleLabel = UILabel()
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, book: Book) {
        self.book = book
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    required init?(coder: NSCoder) {
        print("init from coder not supported")
        return nil
    }
    
    private func initView() {
        layer.cornerRadius = 9
        clipsToBounds = true
        initLayout()
        setupViews()
        bind()
    }
    private func initLayout() {
        contentView.add(mainStackView) { [unowned self] in
            $0.addArranged(self.leftImageView)
            $0.addArranged(self.titleStackView) { [unowned self] in
                $0.addArranged(self.titleLabel)
                $0.addArranged(self.subtitleLabel)
            }
        }
        
    }
    private func setupViews() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.alignment = .top
        mainStackView.distribution = .fill
        mainStackView.spacing = 8
        mainStackView.axis = .horizontal
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.backgroundColor = .quaternarySystemFill
        leftImageView.layer.masksToBounds = true
        leftImageView.layer.cornerRadius = 6
        leftImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        leftImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.alignment = .fill
        titleStackView.distribution = .fill
        titleStackView.spacing = 4
        titleStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    private func bind() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.text = book.title
        subtitleLabel.text = book.subtitle
        leftImageView.setImageUrl(book.imageUrl)
    }
}
