//
//  UILabel+Extension.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.06.2021.
//

import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont? = .avenir20()) {
        self.init()
        self.text = text
        self.font = font
    }
}
