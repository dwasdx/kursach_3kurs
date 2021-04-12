//
//  BaseViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 05.04.2021.
//

import Foundation

public protocol BaseViewModeling: class {
    var isLoading: Bool { get }
    
    var didChange: (() -> Void)? { get set }
    var didGetError: ((_ message: String) -> Void)? { get set }
}

public class BaseViewModel: BaseViewModeling {
    
    public var isLoading = false {
        didSet {
            didChange?()
        }
    }
    
    public var didChange: (() -> Void)? {
        didSet {
            didChange?()
        }
    }
    
    public var didGetError: ((_ message: String) -> Void)?
    
}
