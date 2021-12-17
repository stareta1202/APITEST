//
//  ImageCacheService.swift
//  Karrot
//
//  Created by yjlee12 on 2021/12/17.
//

import Foundation
import UIKit

class ImageCacheService {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}

extension UIImageView {
    func setImageUrl(_ url: String?) {
        guard let url = url else { return }

        DispatchQueue.global(qos: .background).async {
            let cachedKey = NSString(string: url)
            DispatchQueue.main.async {
                if let cachedImage = ImageCacheService.shared.object(forKey: cachedKey) {
                    self.image = cachedImage
                    return
                }
            }
            guard let url = URL(string: url) else { return }
            URLSession.shared.dataTask(with: url) { (data, result, error) in
                guard error == nil else {
                    DispatchQueue.main.async { [weak self] in
                        self?.image = UIImage()
                    }
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    if let data = data, let image = UIImage(data: data) {
                        ImageCacheService.shared.setObject(image, forKey: cachedKey)
                        self?.image = image
                    }
                }
            }.resume()
        }
    }
}
