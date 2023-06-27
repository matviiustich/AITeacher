//
//  Authentication.swift
//  AITeacher
//
//  Created by Александр Устич on 27.06.2023.
//

import SwiftUI

class Authentication: ObservableObject {
    @Published var isValidated = false
    
    func updateValidation(success: Bool) {
        withAnimation {
            isValidated = success
        }
    }
}
