//
//  ContentView.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import SwiftUI
import Firebase
import OpenAI

let openAI = OpenAI(apiToken: "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")

struct ContentView: View {
    @StateObject var lessonsFirebase = LessonFirebaseModel()
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        TabView {
            NavigationStack {
                LessonsTabView(lessonsFirebase: lessonsFirebase)
            }
            .tabItem {
                Label("Lessons", systemImage: "book")
            }
            UserProfileView(lessonsFirebase: lessonsFirebase, selectedLanguage: lessonsFirebase.preferences?.language ?? "English", selectedLearningStyle: lessonsFirebase.preferences?.learningStyle ?? "Sensing", selectedCommunicationStyle: lessonsFirebase.preferences?.communicationStyle ?? "Stochastic", selectedToneStyle: lessonsFirebase.preferences?.toneStyle ?? "Debate", selectedReasoningFramework: lessonsFirebase.preferences?.reasoningFramework ?? "Deductive")
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

