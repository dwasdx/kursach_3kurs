//
//  NameDescribable.swift
//  Messager
//
//  Created by Андрей Журавлев on 08.03.2021.
//

import Foundation

public protocol NameDescribable {
    
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    
    public var typeName: String {
        String(describing: type(of: self))
    }
    
    public static var typeName: String {
        String(describing: self)
    }
}
