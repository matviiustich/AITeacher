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
    @StateObject var lessonsFirebase: LessonFirebaseModel
    @State private var showLessonTitleAlert: Bool = false
    @State private var lessonTitle: String = ""
    
    var body: some View {
        
            List {
                ForEach(lessonsFirebase.lessons, id: \.self) { lesson in
                    NavigationLink(lesson.title) {
                        ChaptersView(lessonsFirebase: lessonsFirebase, lesson: lesson)
                    }
                }
                .onDelete(perform: delete)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showLessonTitleAlert = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    
                }
            }
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    lessonsFirebase.lessons = await lessonsFirebase.retrieveLessons()
                }
                lessonsFirebase.startListening()
            }
            .onDisappear {
                lessonsFirebase.stopListening()
            }
        
        .alert("Lesson Topic", isPresented: $showLessonTitleAlert) {
            TextField("Title", text: $lessonTitle)
            Button("Cancel", role: .cancel, action: {})
            Button {
                withAnimation {
                    lessonsFirebase.createLesson(title: lessonTitle)
                }
                lessonTitle = ""
                showLessonTitleAlert = false
            } label: {
                Text("Save")
            }

        } message: {
            Text("Enter lesson's topic")
        }

    }
    
    func delete(at offsets: IndexSet) {
        if let deletedIndex = offsets.first {
            let deletedLesson = lessonsFirebase.lessons[deletedIndex]
            print("Deleted Lesson ID: \(deletedLesson.id)")
            // Perform deletion logic here
            lessonsFirebase.deleteLesson(deletedLesson)
        }
    }

    
}

struct LessonsTabView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsTabView(lessonsFirebase: LessonFirebaseModel())
    }
}
