//
//  BaseRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 08.03.2021.
//

import UIKit

public protocol BaseRouting: AnyObject {
    var navigationController: UINavigationController { get set }
}

public class BaseRouter {
    
    var tabBarRouter: TabBarRouting
    
    public var navigationController: UINavigationController
    
    init(tabBarRouter: TabBarRouting) {
        
        self.tabBarRouter = tabBarRouter
        
        let nvc = UINavigationController()
        nvc.navigationBar.isHidden = true
        nvc.modalPresentationStyle = .fullScreen        
        self.navigationController = nvc
    }
}
