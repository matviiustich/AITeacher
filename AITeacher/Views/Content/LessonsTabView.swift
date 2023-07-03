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
            List {
                ForEach(lessonsFirebase.lessons, id: \.self) { lesson in
                    NavigationLink(
                        destination: LessonView(lesson: lesson),
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
                .onDelete(perform: delete)
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
                lessonsFirebase.createLesson(title: lessonTitle)
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
        LessonsTabView()
    }
}
