//
//  LessonView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI

let lightGreyColor = #colorLiteral(red: 0.9376311898, green: 0.9411993623, blue: 0.9370459914, alpha: 1)
let grey = #colorLiteral(red: 0.6312714219, green: 0.6313036084, blue: 0.6396345496, alpha: 1)
let darkGrey = #colorLiteral(red: 0.07843136042, green: 0.07843136042, blue: 0.07843136042, alpha: 1)

struct ChapterConversationView: View {
    @ObservedObject var lessonsFirebase: LessonFirebaseModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var lesson: Lesson
    @State var chapterIndex: Int
    @State private var messageText: String = ""
    @State private var canSendMessage: Bool = true
    @State private var proxy: ScrollViewProxy? = nil
    
    @State private var startPos : CGPoint = .zero
    @State private var isSwipping = true
    @State private var direction: String = ""
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.white
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            if lesson.chapters[chapterIndex].conversation.isEmpty {
                VStack {
                    Button(action: {
                        messageText = "/start"
                        sendMessage()
                    }) {
                        Text("Start Lesson")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    HStack {
                        VStack { Divider() }
                        Text("or")
                        VStack { Divider() }
                    }
                    Text("Swipe for the next or previous topics")
                        .font(.system(size: 20))
                }
                .padding()
            } else {
                messagesView
            }
        }
        .navigationBarTitle(lesson.chapters[chapterIndex].title, displayMode: .inline)
        .gesture(DragGesture()
            .onChanged { gesture in
                if self.isSwipping {
                    self.startPos = gesture.location
                    self.isSwipping.toggle()
                }
            }
            .onEnded { gesture in
                let xDist =  abs(gesture.location.x - self.startPos.x)
                let yDist =  abs(gesture.location.y - self.startPos.y)
                if self.startPos.y <  gesture.location.y && yDist > xDist {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                }
                if self.startPos.x > gesture.location.x && yDist < xDist {
                    self.direction = "Left"
                    if chapterIndex < lesson.chapters.count - 1 {
                        withAnimation { chapterIndex += 1 }
                        hapticsFeedback()
                        proxy?.scrollToLastMessage(messages: lesson.chapters[chapterIndex].conversation)
                    }

                }
                else if self.startPos.x < gesture.location.x && yDist < xDist {
                    self.direction = "Right"
                    if chapterIndex > 0 {
                        withAnimation { chapterIndex -= 1 }
                        hapticsFeedback()
                        proxy?.scrollToLastMessage(messages: lesson.chapters[chapterIndex].conversation)
                    }
                }
                self.isSwipping.toggle()
            }
        )
        .dismissKeyboard()
    }
    
    var messagesView: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(lesson.chapters[chapterIndex].conversation) { message in
                            MessageView(message: message)
                        }
                    }
                }
                .onAppear {
                    proxy.scrollToLastMessage(messages: lesson.chapters[chapterIndex].conversation)
                }
                .onChange(of: lesson.chapters[chapterIndex].conversation.count, perform: { _ in
                    proxy.scrollToLastMessage(messages: lesson.chapters[chapterIndex].conversation)
                })
                .padding()
            }
            
            HStack {
                TextField("Type a message", text: $messageText)
                    .frame(maxWidth: .infinity, maxHeight: 34)
                    .padding(.horizontal, 5)
                    .background(colorScheme == .light ? Color(lightGreyColor) : Color(darkGrey))
                    .font(.system(size: 16))
                    .cornerRadius(10)
                    .padding(.leading)
                
                Button(action: sendMessage) {
                    ZStack {
                        if canSendMessage {
                            Image(systemName: "arrow.up")
                                .resizable()
                                .frame(width: 17, height: 17)
                                .padding(9)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                                        .scaleEffect(0.8)
                                )
                        }
                    }
                }
                .disabled(!canSendMessage)
                .padding(.trailing)
            }
            .padding(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        lessonFunction(command: "/test")
                    }) {
                        Label("Test", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        lessonFunction(command: "/continue")
                    }) {
                        Label("Continue", systemImage: "arrow.right.circle")
                    }
                } label: {
                    Image(systemName: "contextualmenu.and.cursorarrow")
                }
            }
        }
    }
    
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = Message(id: UUID().uuidString, text: messageText, isSentByUser: true)
        withAnimation {
            lesson.chapters[chapterIndex].conversation.append(userMessage)
        }
        lesson.chapters[chapterIndex].memory.append(["role" : "user", "content" : messageText])
        messageText = ""
        Task {
            withAnimation {
                canSendMessage = false
            }
            print(lesson.chapters[chapterIndex].memory)
            let lessonCopy = lesson
            let chapterIndexCopy = chapterIndex
            let result = await askTutor(modelInput: lessonCopy.chapters[chapterIndexCopy].memory)
            let resultContent = result["content"] ?? "Error occured while loading the answer"
            lesson.chapters[chapterIndex].memory.append(["role" : "assistant", "content" : resultContent])
            let tutorMessage = Message(id: UUID().uuidString, text: resultContent, isSentByUser: false)
            withAnimation {
                lesson.chapters[chapterIndex].conversation.append(tutorMessage)
                canSendMessage = true
            }
            lessonsFirebase.updateLesson(lesson)
        }
        
    }
    
    // Special commands for the tutor (e.g. /feedback, /test, /plan)
    func lessonFunction(command: String) {
        Task {
            withAnimation {
                canSendMessage = false
            }
            lesson.chapters[chapterIndex].memory.append(["role" : "user", "content" : command])
            let lessonCopy = lesson
            let chapterIndexCopy = chapterIndex
            let result = await askTutor(modelInput: lessonCopy.chapters[chapterIndexCopy].memory)
            let resultContent = result["content"] ?? "Error occured while loading the answer"
            lesson.chapters[chapterIndex].memory.append(["role" : "assistant", "content" : resultContent])
            let tutorMessage = Message(id: UUID().uuidString, text: resultContent, isSentByUser: false)
            withAnimation {
                lesson.chapters[chapterIndex].conversation.append(tutorMessage)
            }
            withAnimation {
                canSendMessage = true
            }
        }
    }
    
}

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        let lesson = Lesson(id: UUID().uuidString, title: "Physics", lastUpdated: .now, chapters: [Chapter(id: UUID().uuidString, title: "Motion", conversation: [], memory: [[:]])])
        ChapterConversationView(lessonsFirebase: LessonFirebaseModel(), lesson: .constant(lesson), chapterIndex: 0)
    }
}
