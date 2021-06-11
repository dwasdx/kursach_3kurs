//
//  OneLineTextField.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.06.2021.
//

import UIKit

class OneLineTextField: UITextField {
    
    convenience init(font: UIFont? = .avenir20()) {
        self.init()
        
        self.font = font
        self.borderStyle = .none
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomView = UIView(frame: CGRect.zero)
        bottomView.backgroundColor = .textFieldWhite
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomView)
        bottomView.anchor(top: nil,
                          leading: leadingAnchor,
                          bottom: bottomAnchor,
                          trailing: trailingAnchor,
                          size: CGSize(width: 0, height: 1))
    }
    
}
