//
//  LoginView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI
import Combine
import FirebaseAnalyticsSwift
import _AuthenticationServices_SwiftUI

private enum FocusableField: Hashable {
    case email
    case password
}

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
    private func signInWithEmailPassword() {
        Task {
            if await viewModel.signInWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    private func signInWithGoogle() {
        Task {
            if await viewModel.signInWithGoogle() == true {
                dismiss()
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "at")
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
            
            HStack {
                Image(systemName: "lock")
                SecureField("Password", text: $viewModel.password)
                    .focused($focus, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        signInWithEmailPassword()
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)
            
            if !viewModel.errorMessage.isEmpty {
                VStack {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            Button(action: signInWithEmailPassword) {
                if viewModel.authenticationState != .authenticating {
                    Text("Login")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!viewModel.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
            HStack {
                VStack { Divider() }
                Text("or")
                VStack { Divider() }
            }
            
            Button(action: signInWithGoogle) {
                HStack {
                    Image("g-logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            }
            .frame(minHeight: 55)
            .buttonStyle(.bordered)
            
            
            // Implement sign in with Apple (Apple developer account required)
            SignInWithAppleButton { request in
                
            } onCompletion: { result in
                
            }
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(maxWidth: .infinity, maxHeight: 55)

            HStack {
                Text("Don't have an account yet?")
                Button(action: { viewModel.switchFlow() }) {
                    Text("Sign up")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .bottom], 50)
            
        }
        .listStyle(.plain)
        .padding()
        .analyticsScreen(name: "\(Self.self)")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
            LoginView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(AuthenticationViewModel())
    }
}
