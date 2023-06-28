//
//  LessonsTabView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI

struct LessonsTabView: View {
    
    let lessons: [Lesson] = [Lesson(title: "Physics", conversation: [["user": "hello"]]), Lesson(title: "Maths", conversation: [["user": "Hello"]])]
    
    var body: some View {
        NavigationView {
            List(lessons) { lesson in
                NavigationLink(destination: EmptyView()) {
                    Text(lesson.title)
                        .font(.headline)
                }
            }
            .toolbar {
                
            }
        }
    }
}

struct LessonsTabView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsTabView()
    }
}
