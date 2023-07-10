//
//  LessonView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI
import OpenAI

let lightGrayColor = #colorLiteral(red: 0.9376311898, green: 0.9411993623, blue: 0.9370459914, alpha: 1)
let gray = #colorLiteral(red: 0.6312714219, green: 0.6313036084, blue: 0.6396345496, alpha: 1)
let darkGray = #colorLiteral(red: 0.07843136042, green: 0.07843136042, blue: 0.07843136042, alpha: 1)
let myGrayColor = #colorLiteral(red: 0.8163583279, green: 0.8272079229, blue: 0.8522316813, alpha: 1)
let myDarkGrayColor = #colorLiteral(red: 0.1686274707, green: 0.1686274707, blue: 0.1686274707, alpha: 1)

struct ChapterConversationView: View {
    @EnvironmentObject var lessonsFirebase: LessonFirebaseModel
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
                        hapticsFeedback()
                        withAnimation {
                            lessonFunction(command: "/start")
                        }
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
        .navigationBarBackButtonHidden(canSendMessage ? false : true)
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
                if canSendMessage {
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
            VStack {
                HStack {
                    TextField("Type a message", text: $messageText)
                        .frame(maxWidth: .infinity, maxHeight: 34)
                        .padding(.horizontal, 5)
                        .background(colorScheme == .light ? Color(lightGrayColor) : Color(darkGray))
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
                VStack {
                    HStack {
                        Button("Continue") {
                            hapticsFeedback()
                            lessonFunction(command: "/Continue")
                        }
                        .disabled(!canSendMessage)
                        Spacer()
                        Button("Test") {
                            hapticsFeedback()
                            lessonFunction(command: "/Test")
                        }
                        .disabled(!canSendMessage)
                    }
                    .padding(.horizontal)
                    .frame(idealWidth: .infinity, maxWidth: .infinity,
                           idealHeight: 40, maxHeight: 40,
                           alignment: .center)
                    .background(colorScheme == .light ? Color(myGrayColor) : Color(myDarkGrayColor))
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
            let messages = memoryToChat(memory: lesson.chapters[chapterIndex].memory)
            let query = ChatQuery(model: .gpt3_5Turbo_16k, messages: messages)
            lesson.chapters[chapterIndex].conversation.append(Message(id: UUID().uuidString, text: "", isSentByUser: false))
            let lastIndex = lesson.chapters[chapterIndex].conversation.indices.last
            do {
                for try await result in openAI.chatsStream(query: query) {
                    if let chunk = result.choices.first?.delta.content {
                        if let lastIndex {
                            lesson.chapters[chapterIndex].conversation[lastIndex].text += chunk
                        }
                    }
                }
            } catch {
                print("Error occured while streaming the tutor's response")
            }
            if let lastIndex {
                lesson.chapters[chapterIndex].memory.append(["role" : "assistant", "content" : lesson.chapters[chapterIndex].conversation[lastIndex].text])
            }
            lessonsFirebase.updateLesson(lesson)
            withAnimation {
                canSendMessage = true
            }
        }
        
    }
    
    // Special commands for the tutor (e.g. /feedback, /test, /plan)
    func lessonFunction(command: String) {
        Task {
            withAnimation {
                canSendMessage = false
            }
            lesson.chapters[chapterIndex].memory.append(["role" : "system", "content" : command])
            let messages = memoryToChat(memory: lesson.chapters[chapterIndex].memory)
            let query = ChatQuery(model: .gpt3_5Turbo_16k, messages: messages)
//            let query = ChatQuery(model: .gpt4, messages: messages)
            withAnimation {
                lesson.chapters[chapterIndex].conversation.append(Message(id: UUID().uuidString, text: "", isSentByUser: false))
            }
            let lastIndex = lesson.chapters[chapterIndex].conversation.indices.last
            do {
                for try await result in openAI.chatsStream(query: query) {
                    if let chunk = result.choices.first?.delta.content {
//                        print(chunk)
                        if let lastIndex {
                            lesson.chapters[chapterIndex].conversation[lastIndex].text += chunk
                        }
                    }
                }
            } catch {
                print("Error occured while streaming the tutor's response")
            }
            if let lastIndex {
                lesson.chapters[chapterIndex].memory.append(["role" : "assistant", "content" : lesson.chapters[chapterIndex].conversation[lastIndex].text])
            }
            lessonsFirebase.updateLesson(lesson)
            withAnimation {
                canSendMessage = true
            }
        }
    }
    
}

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        let lesson = Lesson(id: UUID().uuidString, depthLevel: 3, title: "Physics", lastUpdated: .now, chapters: [Chapter(id: UUID().uuidString, title: "Motion", conversation: [Message(id: "someID", text: "Hello!", isSentByUser: true)], memory: [[:]])])
        ChapterConversationView(lesson: .constant(lesson), chapterIndex: 0)
            .environmentObject(LessonFirebaseModel())
    }
}
