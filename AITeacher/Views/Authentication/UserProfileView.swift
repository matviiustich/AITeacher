//
//  UserProfileView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct UserProfileView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State var presentingConfirmationDialog = false
    
    @ObservedObject var lessonsFirebase: LessonFirebaseModel
    
    // Preference variables
    @State private var selectedLearningStyle = "Sensing"
    let learningStyles = ["Sensing", "Inductive", "Active", "Sequential", "Intuitive", "Verbal", "Deductive", "Reflective", "Global"]
    @State private var selectedCommunicationStyle = "Stochastic"
    let communicationStyles = ["Stochastic", "Formal", "Textbook", "Layman", "Story Telling", "Socratic", "Humorous"]
    @State private var selectedToneStyle = "Debate"
    let toneStyles = ["Debate", "Encouraging", "Neutral", "Informative", "Friendly"]
    @State private var selectedReasoningFramework = "Deductive"
    let reasoningFrameworks = ["Deductive", "Inductive", "Abductive", "Analogical", "Causal"]
    
    var body: some View {
        Form {
            Section {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 100 , height: 100)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .clipped()
                            .padding(4)
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                        Spacer()
                    }
                }
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            Section("Email") {
                Text(viewModel.displayName)
            }
            Section("Preferences") {
                VStack {
                    Picker("Learning Style", selection: $selectedLearningStyle) {
                        ForEach(learningStyles, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Communication Style", selection: $selectedCommunicationStyle) {
                        ForEach(communicationStyles, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Tone Style", selection: $selectedToneStyle) {
                        ForEach(toneStyles, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Reasoning Framework", selection: $selectedReasoningFramework) {
                        ForEach(reasoningFrameworks, id: \.self) {
                            Text($0)
                        }
                    }
                }
                .onChange(of: selectedLearningStyle) { _ in
                    updatePreferences()
                }
                .onChange(of: selectedCommunicationStyle) { _ in
                    updatePreferences()
                }
                .onChange(of: selectedToneStyle) { _ in
                    updatePreferences()
                }
                .onChange(of: selectedReasoningFramework) { _ in
                    updatePreferences()
                }
            }
            Section {
                Button(role: .cancel, action: signOut) {
                    HStack {
                        Spacer()
                        Text("Sign out")
                        Spacer()
                    }
                }
            }
            Section {
                Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
                    HStack {
                        Spacer()
                        Text("Delete Account")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen(name: "\(Self.self)")
        .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                            isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive, action: deleteAccount)
            Button("Cancel", role: .cancel, action: { })
        }
    }
    
    private func deleteAccount() {
        Task {
            if await viewModel.deleteAccount() == true {
                dismiss()
            }
        }
    }
    
    private func signOut() {
        viewModel.signOut()
    }
    
    private func updatePreferences() {
        lessonsFirebase.updateUserPreferences(learningStyle: selectedLearningStyle,
                                              communicationStyle: selectedCommunicationStyle,
                                              toneStyle: selectedToneStyle,
                                              reasoningFramework: selectedReasoningFramework)
    }
    
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserProfileView(lessonsFirebase: LessonFirebaseModel())
                .environmentObject(AuthenticationViewModel())
        }
    }
}
