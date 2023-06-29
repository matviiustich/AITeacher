//
//  LessonsTabView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI

struct LessonsTabView: View {
    @State private var selectedLesson: Lesson? = nil
    @State private var shouldAnimate = false
    
    let lessons = [Lesson(title: "Physics", conversation: [], memory: [])]
    
    var body: some View {
        NavigationView {
            List(lessons) { lesson in
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
            .navigationBarTitle("Lessons")
            .onAppear {
                withAnimation {
                    selectedLesson = nil
                }
            }
        }
        
    }
}

struct LessonsTabView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsTabView()
    }
}
