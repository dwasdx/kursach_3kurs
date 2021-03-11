//
//  UIStoryboard+Extensions.swift
//  Messager
//
//  Created by Андрей Журавлев on 08.03.2021.
//

import UIKit

public protocol StoryboardLoadable: NameDescribable {
    static var storyboardName: String { get }
    static var controllerIdentifier: String? { get }
    
    static func initFromItsStoryboard() -> Self
}

extension UIViewController: StoryboardLoadable {}

extension StoryboardLoadable where Self: UIViewController {
    
    public static var storyboardName: String {
        typeName
    }
    
    public static var controllerIdentifier: String? {
        nil
    }
    
    public static func initFromItsStoryboard() -> Self {
        
        if Bundle.main.path(forResource: typeName, ofType: "xib") != nil ||
            Bundle.main.path(forResource: typeName, ofType: "nib") != nil {
            let vc = self.init()
            return vc
        }
        
        if Bundle.main.path(forResource: storyboardName, ofType: "storyboardc") != nil {
            let storyboard = UIStoryboard(name: storyboardName, bundle: .main)
            
            if let controllerIdentifier = controllerIdentifier {
                guard let vc = storyboard.instantiateViewController(withIdentifier: controllerIdentifier) as? Self else {
                    fatalError("Couldn't instantiate ViewController with identifier: \(Self.typeName)")
                }
                
                return vc
            }
            
            if let vc = storyboard.instantiateInitialViewController() as? Self {
                return vc
            } else {
                fatalError("Could not load inital ViewController: \(Self.typeName)")
            }
        }
        
        fatalError("No xib or storyboard found for ViewController: \(Self.typeName)")
    }
}

