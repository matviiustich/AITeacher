//
//  UIApplication+Extension.swift
//  AITeacher
//
//  Created by Александр Устич on 27.06.2023.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
