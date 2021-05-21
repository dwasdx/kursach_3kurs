//
//  WelcomeScreenViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 18.04.2021.
//

import UIKit

protocol WelcomeScreenRouting {
    func openTabBarScreen()
}

protocol WelcomeScreenViewModeling: BaseViewModeling {
    var avatarPngData: Data? { get set }
}

class WelcomeScreenViewController: BaseViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var router: WelcomeScreenRouting?
    var viewModel: WelcomeScreenViewModeling! {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        if let data = viewModel.avatarPngData {
            avatarImageView.image = UIImage(data: data)
        }
    }
    
    @IBAction func onContinue() {
        router?.openTabBarScreen()
    }
}
