//
//  NSLayoutConstraint+Extension.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.06.2021.
//

import UIKit

extension UIView {
    enum AnchorsSize {
        case width, height
    }
    
    func anchorSize(to view: UIView, withDirections anchors: [AnchorsSize]) {
        if anchors.contains(.width) {
            widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
        if anchors.contains(.height) {
            heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }
    }
    
    func sizeAnchors(with size: CGSize) {
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        sizeAnchors(with: size)
    }
    
    func fillSuperview(padding: UIEdgeInsets) {
        anchor(top: superview?.topAnchor,
               leading: superview?.leadingAnchor,
               bottom: superview?.bottomAnchor,
               trailing: superview?.trailingAnchor,
               padding: padding)
    }
    
    func fillSuperview() {
        fillSuperview(padding: .zero)
    }
    
    
}
