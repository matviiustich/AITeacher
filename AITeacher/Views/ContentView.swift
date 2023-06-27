//
//  ContentView.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var authentication: Authentication
    var body: some View {
        NavigationView {
            VStack {
                Text("Your lessons")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log out") {
                        authentication.updateValidation(success: false)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

