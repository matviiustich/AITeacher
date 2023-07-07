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
    @ObservedObject var lessonsFirebase: LessonFirebaseModel
    @State private var showLessonTitleAlert: Bool = false
    @State private var lessonTitle: String = ""
    @State var createButtonPressed: Bool = false
    
    var body: some View {
        List {
            ForEach(lessonsFirebase.lessons, id: \.self) { lesson in
                NavigationLink(lesson.title) {
                    ChaptersView(lessonsFirebase: lessonsFirebase, lesson: lesson)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        lessonsFirebase.deleteLesson(lesson)
                        hapticsFeedback()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
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
        .popover(isPresented: $showLessonTitleAlert) {
            CreateLessonView(lessonsFirebase: lessonsFirebase, buttonPressed: $createButtonPressed)
                .interactiveDismissDisabled(createButtonPressed ? true : false)
        }
        
    }
    
}

struct LessonsTabView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsTabView(lessonsFirebase: LessonFirebaseModel())
    }
}
