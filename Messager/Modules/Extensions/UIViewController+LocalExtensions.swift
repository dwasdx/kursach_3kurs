//
//  UIViewController+LocalExtensions.swift
//  Messager
//
//  Created by Андрей Журавлев on 05.04.2021.
//

import UIKit

fileprivate weak var vSpinner : UIView?

extension UIViewController {
    
    func showErrorAlert(title: String = "Error", message: String, okHandler: ((UIAlertAction)->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
        
        present(alert, animated: true)
    }
    
    func showMessageAlert(title: String = "Message", message: String, okHandler: ((UIAlertAction)->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
        
        present(alert, animated: true)
    }
    
    func showConformationAlert(title: String = "Message", message: String, actionHandler: ((UIAlertAction)->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: actionHandler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: actionHandler))
        
        present(alert, animated: true)
    }
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
