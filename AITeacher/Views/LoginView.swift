//
//  LoginView.swift
//  AITeacher
//
//  Created by Александр Устич on 27.06.2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var loginVM = LoginViewModel()
    @EnvironmentObject var authentication: Authentication
    
    var body: some View {
        VStack {
            TextField("Email", text: $loginVM.creadentials.email)
                .keyboardType(.emailAddress)
                .padding(.bottom)
            SecureField("Password", text: $loginVM.creadentials.password)
            
            Group {
                Button("Log In") {
                    loginVM.login { success in
                        authentication.updateValidation(success: success)
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
                .padding()
                
                Button("Register") {
                    loginVM.register { success in
                        authentication.updateValidation(success: success)
                    }
                }
            }
            .offset(y: 180)
        }
        .padding()
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
