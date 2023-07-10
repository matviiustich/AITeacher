//
//  ChaptersView.swift
//  AITeacher
//
//  Created by Александр Устич on 03.07.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ChaptersView: View {
    @EnvironmentObject var lessonsFirebase: LessonFirebaseModel
    @State var lesson: Lesson
    @State private var selectedChapter: Chapter? = nil
    @State var selectedDepthLevel = "1"
    
    @State private var showTabBar = true
    @State private var buttonPressed = false
    
    let depthLevels = (1...10).map { String($0) }
    
    var body: some View {
        
        Group {
            if lesson.chapters.isEmpty {
                Text("Sorry, the error occurred while creating this lesson. Try to delete this lesson, and then create it again.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .padding()
            } else {
                List {
                    ForEach(lesson.chapters.indices, id: \.self) { index in
                        let chapter = lesson.chapters[index]
                        NavigationLink(chapter.title) {
                            ChapterConversationView(lesson: $lesson, chapterIndex: index)
                                .environmentObject(lessonsFirebase)
                                .onAppear {
                                    withAnimation { self.showTabBar = false }
                                }
                                .onDisappear {
                                    withAnimation { self.showTabBar = true }
                                }
                        }
                    }
                }
                
            }
        }
        .toolbar(showTabBar ? .visible : .hidden, for: .tabBar)
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {     
            withAnimation {
                selectedChapter = nil
            }
        }
    }
    
}

struct ChaptersView_Previews: PreviewProvider {
    static var previews: some View {
        let lesson = Lesson(id: "lessonID", depthLevel: 8, title: "Physics", lastUpdated: .now, chapters: [])
        ChaptersView(lesson: lesson)
            .environmentObject(LessonFirebaseModel())
    }
}
