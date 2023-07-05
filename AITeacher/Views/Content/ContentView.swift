//
//  ContentView.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject private var lessonsFirebase = LessonFirebaseModel()
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        TabView {
            NavigationStack {
                LessonsTabView(lessonsFirebase: lessonsFirebase)
            }
            .tabItem {
                Label("Lessons", systemImage: "book")
            }
            UserProfileView(lessonsFirebase: lessonsFirebase)
                .environmentObject(viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

