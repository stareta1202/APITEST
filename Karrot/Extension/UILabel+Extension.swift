//
//  UILabel+Extension.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/17.
//

import UIKit

extension UILabel {
    func custom(font: UIFont) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = font
        return label
    }
}
