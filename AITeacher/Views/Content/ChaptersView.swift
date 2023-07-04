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
    @ObservedObject var lessonsFirebase = LessonFirebaseModel()
    @State var lesson: Lesson
    @State private var selectedChapter: Chapter? = nil
    @State private var selectedDepthLevel = "1"
    
    let depthLevels = (1...10).map { String($0) }
    
    var body: some View {
        
        Group {
            if lesson.chapters.isEmpty {
                
                Form {
                    VStack {
                        Section {
                            Picker("Depth Level", selection: $selectedDepthLevel) {
                                ForEach(depthLevels, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        Button {
                            Task {
                                await createChapters(lesson: lesson.title, depthLevel: "Level_\(selectedDepthLevel)", using: createChapter)
                            }
                        } label: {
                            Text("Generate lesson plan")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                    
            } else {
                List {
                    ForEach(lesson.chapters.indices, id: \.self) { index in
                        let chapter = lesson.chapters[index]
                        NavigationLink(
                            destination: ChapterConversationView(lesson: lesson, chapterIndex: index),
                            tag: chapter,
                            selection: $selectedChapter
                        ) {
                            Text(chapter.title)
                        }
                        .onTapGesture {
                            print(chapter)
                            withAnimation {
                                selectedChapter = chapter
                            }
                        }
                    }
                }
            }
        }
        .toolbar(selectedChapter != nil ? .hidden : .visible, for: .tabBar)
        .navigationBarTitle(lesson.title)
        .onAppear {
            Task {
                lessonsFirebase.preferences = await lessonsFirebase.retrieveUserPreferences()
            }
            lessonsFirebase.startListening()
            withAnimation {
                selectedChapter = nil
            }
        }
        .onDisappear {
            lessonsFirebase.stopListening()
        }
        
    }
    
    func createChapter(topic: String) {
        let config = "Depth level is Level_\(selectedDepthLevel). Learning style is \(lessonsFirebase.preferences?.learningStyle ?? "auto"). Communication style is \(lessonsFirebase.preferences?.communicationStyle ?? "auto"). Tone style is \(lessonsFirebase.preferences?.toneStyle ?? "auto"). Reasoning framework is \(lessonsFirebase.preferences?.reasoningFramework ?? "auto")"
        withAnimation {
            lesson.chapters.append(Chapter(id: UUID().uuidString, title: topic, conversation: [], memory: [["role" : "system", "content" : loadPrompt()], ["role" : "system", "content" : "This lesson is about \(topic)"], ["role" : "system", "content" : config]]))
        }
        lessonsFirebase.updateLesson(lesson)
    }
    
}

struct ChaptersView_Previews: PreviewProvider {
    static var previews: some View {
        let lesson = Lesson(id: "lessonID", title: "Physics", lastUpdated: .now, chapters: [])
        ChaptersView(lesson: lesson)
    }
}
