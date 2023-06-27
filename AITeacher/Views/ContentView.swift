//
//  ContentView.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    
    var body: some View {
        if userIsLoggedIn {
            TutorView()
        } else {
            content
        }
    }
    
    var content: some View {
        VStack (spacing: 20) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .padding(.bottom)
            SecureField("Password", text: $password)
            
            Group {
                Button {
                    register()
                } label: {
                    Text("Sign Up")
                        .bold()
                        .frame(width: 250, height: 45)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                
                Button {
                    login()
                } label: {
                    Text("Login")
                        .bold()
                        .font(.system(size: 20))
                }
            }
            .offset(y: 150)
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userIsLoggedIn.toggle()
                    }
                }
            }
        }
        .padding()
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
