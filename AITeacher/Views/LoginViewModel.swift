//
//  LoginViewModel.swift
//  AITeacher
//
//  Created by Александр Устич on 27.06.2023.
//

import Foundation
import Firebase

class LoginViewModel: ObservableObject {
    @Published var creadentials = Credentials()
    
    func login(completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: creadentials.email, password: creadentials.password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func register(completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: creadentials.email, password: creadentials.password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
