//
//  CreateLessonView.swift
//  AITeacher
//
//  Created by Александр Устич on 07.07.2023.
//

import SwiftUI

struct CreateLessonView: View {
    @EnvironmentObject var lessonsFirebase: LessonFirebaseModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var lessonTopic: String = ""
    @State var selectedDepthLevel = "1"
    @State var lesson: Lesson?
    
    @Binding var buttonPressed: Bool
    let depthLevels = (1...10).map { String($0) }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    VStack {
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
            }
            .scrollContentBackground(.hidden)
            Button {
                if lessonTopic != "" {
                    buttonPressed = true
                    Task {
                        do {
                            try await lessonsFirebase.createLesson(title: lessonTopic, depthLevel: Int(selectedDepthLevel)!)
                        } catch {
                            print(error)
                        }
//                        selectedDepthLevel = "1"
                        buttonPressed = false
                        dismiss()
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
    }
    
}

struct CreateLessonView_Previews: PreviewProvider {
    static var previews: some View {
        CreateLessonView(buttonPressed: .constant(false))
            .environmentObject(LessonFirebaseModel())
    }
}
