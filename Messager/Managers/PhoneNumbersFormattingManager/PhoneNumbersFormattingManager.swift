//
//  PhoneNumbersFormattingManager.swift
//  Messager
//
//  Created by Андрей Журавлев on 31.05.2021.
//

import Foundation
import PhoneNumberKit

protocol PhoneNumberFormatting: AnyObject {
    func parseDecimalNumber(_ decimalString: String) -> String
}

class PhoneNumbersFormattingManager {
    let phoneNumberKit: PhoneNumberKit
    
    static let shared = PhoneNumbersFormattingManager()
    private init() {
        self.phoneNumberKit = PhoneNumberKit()
    }
}

extension PhoneNumbersFormattingManager: PhoneNumberFormatting {
    func parseDecimalNumber(_ decimalString: String) -> String {
        let number = try? phoneNumberKit.parse(decimalString)
        return number?.numberString ?? decimalString
    }
}
