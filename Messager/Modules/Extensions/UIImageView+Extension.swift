//
//  UIImageView+Extension.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.06.2021.
//

import UIKit

extension UIImageView {
    convenience init(image: UIImage?, contentMode: UIView.ContentMode) {
        self.init()
        self.image = image
        self.contentMode = contentMode
    }
}
