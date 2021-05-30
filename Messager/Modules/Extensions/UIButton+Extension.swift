//
//  UIButton+Extension.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.06.2021.
//

import UIKit

extension UIButton {
    convenience init(tittle: String,
                     titleColor: UIColor,
                     backgroundColor: UIColor,
                     font: UIFont? = .avenir20(),
                     isShadow: Bool = false,
                     cornerRadius: CGFloat = 4) {
        self.init(type: .system)
        setTitle(tittle, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        titleLabel?.font = font
        layer.cornerRadius = cornerRadius
        if isShadow {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.2
        }
    }
}
