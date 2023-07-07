//
//  CreateLessonView.swift
//  AITeacher
//
//  Created by Александр Устич on 07.07.2023.
//

import SwiftUI

struct CreateLessonView: View {
    @ObservedObject var lessonsFirebase: LessonFirebaseModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var lessonTopic: String = ""
    @State var selectedDepthLevel = "1"
    @State var depthLevel = "1"
    @State var lesson: Lesson?
    
    @Binding var buttonPressed: Bool
    let depthLevels = (1...10).map { String($0) }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Enter the lesson's topic", text: $lessonTopic)
                        .padding()
                        .background(colorScheme == .light ? Color(lightGrayColor) : Color(darkGray))
                        .font(.system(size: 16))
                        .cornerRadius(10)
                    Picker("Depth Level", selection: $selectedDepthLevel) {
                        ForEach(depthLevels, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            Button {
                if lessonTopic != "" {
                    buttonPressed = true
                    lessonsFirebase.createLesson(title: lessonTopic) { createdLesson in
                        if createdLesson != nil {
                            lesson = createdLesson
                            Task {
                                do {
                                    depthLevel = selectedDepthLevel
                                    try await createChapters(lesson: lessonTopic, depthLevel: depthLevel, language: lessonsFirebase.preferences?.language ?? "English", using: createChapter)
                                } catch {
                                    lessonsFirebase.deleteLesson(lesson!)
                                }
                                buttonPressed = false
                                dismiss()
                            }
                        }
                    }
                }
            } label: {
                if !buttonPressed {
                    Text("Generate lesson plan")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .disabled(buttonPressed)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            Text("Note: You won't be able to change the configuration for this lesson after generating the plan")
                .multilineTextAlignment(.center)
                .padding()
        }
        .dismissKeyboard()
    }
    
    func createChapter(topic: String) {
        let config = "The language is \(lessonsFirebase.preferences?.language ?? "English"). Depth level is Level_\(selectedDepthLevel). Learning style is \(lessonsFirebase.preferences?.learningStyle ?? "auto"). Communication style is \(lessonsFirebase.preferences?.communicationStyle ?? "auto"). Tone style is \(lessonsFirebase.preferences?.toneStyle ?? "auto"). Reasoning framework is \(lessonsFirebase.preferences?.reasoningFramework ?? "auto")"
        withAnimation {
            lesson!.chapters.append(Chapter(id: UUID().uuidString, title: topic, conversation: [], memory: [["role" : "system", "content" : loadPrompt()], ["role" : "system", "content" : "The subject is \(lessonTopic). The current lesson is about \(topic)."], ["role" : "system", "content" : config]]))
        }
        lessonsFirebase.updateLesson(lesson!)
    }
    
}

struct CreateLessonView_Previews: PreviewProvider {
    static var previews: some View {
        CreateLessonView(lessonsFirebase: LessonFirebaseModel(), buttonPressed: .constant(false))
    }
}
