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
    @EnvironmentObject var lessonsFirebase: LessonFirebaseModel
    @State private var showLessonTitleAlert: Bool = false
    @State private var lessonTitle: String = ""
    @State var createButtonPressed: Bool = false
    
    var body: some View {
        List {
            ForEach(lessonsFirebase.lessons, id: \.self) { lesson in
                NavigationLink(lesson.title) {
                    ChaptersView(lesson: lesson)
                        .environmentObject(lessonsFirebase)
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
        .onAppear {
            Task {
                lessonsFirebase.lessons = await lessonsFirebase.retrieveLessons()
            }
            lessonsFirebase.startListening()
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
            CreateLessonView(buttonPressed: $createButtonPressed)
                .environmentObject(lessonsFirebase)
                .interactiveDismissDisabled(createButtonPressed ? true : false)
        }
        
    }
    
}

struct LessonsTabView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsTabView()
            .environmentObject(LessonFirebaseModel())
    }
}
