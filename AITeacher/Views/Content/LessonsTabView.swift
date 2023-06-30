//
//  LessonsTabView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct LessonsTabView: View {
    @StateObject private var lessonsFirebase = LessonFirebaseModel()
    @State private var selectedLesson: Lesson? = nil
    @State private var showLessonTitleAlert: Bool = false
    @State private var lessonTitle: String = ""
    
    var body: some View {
        NavigationView {
            List(lessonsFirebase.lessons) { lesson in
                NavigationLink(
                    destination: LessonView(),
                    tag: lesson,
                    selection: $selectedLesson
                ) {
                    Text(lesson.title)
                        .font(.headline)
                }
                .onTapGesture {
                    withAnimation {
                        selectedLesson = lesson
                    }
                }
            }
            .toolbar(selectedLesson != nil ? .hidden : .visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showLessonTitleAlert = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    
                }
            }
            .navigationBarTitle("Lessons")
            .onAppear {
                lessonsFirebase.startListening()
                withAnimation {
                    selectedLesson = nil
                }
            }
            .onDisappear {
                lessonsFirebase.stopListening()
            }
        }
        .alert("Lesson Topic", isPresented: $showLessonTitleAlert) {
            TextField("Title", text: $lessonTitle)
            Button("Cancel", role: .cancel, action: {})
            Button {
                lessonsFirebase.storeLesson(Lesson(title: lessonTitle, lastUpdated: .now, conversation: [], memory: [[:]]))
                showLessonTitleAlert = false
            } label: {
                Text("Save")
            }

        } message: {
            Text("Enter lesson's topic")
        }

    }
    
}

struct LessonsTabView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsTabView()
    }
}
