//
//  LessonsTabView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI

struct LessonsTabView: View {
    @State private var selectedLesson: Lesson? = nil
    
    let lessons: [Lesson] = [Lesson(title: "Physics", conversation: [["user": "hello"]]), Lesson(title: "Maths", conversation: [["user": "Hello"]])]
    
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
                    selectedLesson = lesson
                }
            }
            .toolbar(selectedLesson != nil ? .hidden : .visible, for: .tabBar)
            .navigationBarTitle("Lessons")
            .onAppear {
                selectedLesson = nil
            }
        }
        
    }
}

struct LessonsTabView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsTabView()
    }
}
