//
//  AITeacherApp.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        print(db)
        
        return true
    }
}

@main
struct AITeacherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Preference variables
//    @State var selectedLearningStyle = "Sensing"
//    let learningStyles = ["Sensing", "Inductive", "Active", "Sequential", "Intuitive", "Verbal", "Deductive", "Reflective", "Global"]
//    @State var selectedCommunicationStyle = "Stochastic"
//    let communicationStyles = ["Stochastic", "Formal", "Textbook", "Layman", "Story Telling", "Socratic", "Humorous"]
//    @State var selectedToneStyle = "Debate"
//    let toneStyles = ["Debate", "Encouraging", "Neutral", "Informative", "Friendly"]
//    @State var selectedReasoningFramework = "Deductive"
//    let reasoningFrameworks = ["Deductive", "Inductive", "Abductive", "Analogical", "Causal"]
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AuthenticatedView {
                    
                    VStack {
                        Text("Welcome to the Classroom!")
                            .font(.title)
                            .bold()
//                        Form {
//                            Section("Preferences") {
//                                VStack {
//                                    Picker("Learning Style", selection: $selectedLearningStyle) {
//                                        ForEach(learningStyles, id: \.self) {
//                                            Text($0)
//                                        }
//                                    }
//                                    Picker("Communication Style", selection: $selectedCommunicationStyle) {
//                                        ForEach(communicationStyles, id: \.self) {
//                                            Text($0)
//                                        }
//                                    }
//                                    Picker("Tone Style", selection: $selectedToneStyle) {
//                                        ForEach(toneStyles, id: \.self) {
//                                            Text($0)
//                                        }
//                                    }
//                                    Picker("Reasoning Framework", selection: $selectedReasoningFramework) {
//                                        ForEach(reasoningFrameworks, id: \.self) {
//                                            Text($0)
//                                        }
//                                    }
//                                }
//
//                            }
//                        }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } content: {
//                    ContentView(selectedLearningStyle: $selectedLearningStyle, selectedCommunicationStyle: $selectedCommunicationStyle, selectedToneStyle: $selectedToneStyle, selectedReasoningFramework: $selectedReasoningFramework)
                    ContentView()
                }
            }
        }
    }
    
}
