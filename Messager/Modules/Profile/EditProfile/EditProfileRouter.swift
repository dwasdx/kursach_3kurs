//
//  EditProfileRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 19.05.2021.
//

import UIKit

final class EditProfileRouter {
    weak var viewController: UIViewController?
}

extension EditProfileRouter: EditProfileRouting {
    func dismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
