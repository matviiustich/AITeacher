//
//  LessonView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI

let lightGreyColor = #colorLiteral(red: 0.9376311898, green: 0.9411993623, blue: 0.9370459914, alpha: 1)
let grey = #colorLiteral(red: 0.6312714219, green: 0.6313036084, blue: 0.6396345496, alpha: 1)
let purpleColor = #colorLiteral(red: 0.6149501204, green: 0.6350134015, blue: 0.9986490607, alpha: 1)

struct LessonView: View {
    @State private var lesson = Lesson(title: "Physics", lastUpdated: .now, conversation: [], memory: [["role": "system", "content" : loadPrompt()]])
    @State private var messageText: String = ""
    @State private var canSendMessage: Bool = true
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(lesson.conversation) { message in
                            MessageView(message: message)
                        }
                    }
                }
                .onChange(of: lesson.conversation.count, perform: { _ in
                    proxy.scrollToLastMessage(messages: lesson.conversation)
                })
                .padding()
            }
            
            HStack {
                TextField("Type a message", text: $messageText)
                    .frame(maxWidth: .infinity, maxHeight: 34)
                    .padding(.horizontal, 5)
                    .background(Color(lightGreyColor))
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
                                .background(Color(purpleColor))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .stroke(Color(purpleColor), lineWidth: 3)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(purpleColor)))
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
        .navigationBarTitle(lesson.title, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        lessonFunction(command: "/feedback")
                    }) {
                        Label("Feedback", systemImage: "message")
                    }
                    
                    Button(action: {
                        lessonFunction(command: "/test")
                    }) {
                        Label("Test", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        lessonFunction(command: "/config")
                    }) {
                        Label("Config", systemImage: "gear")
                    }
                    
                    Button(action: {
                        lessonFunction(command: "/plan")
                    }) {
                        Label("Plan", systemImage: "calendar")
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

        .dismissKeyboard()
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = Message(text: messageText, isSentByUser: true)
        withAnimation {
            lesson.conversation.append(userMessage)
        }
        lesson.memory.append(["role" : "user", "content" : messageText])
        messageText = ""
        Task {
            withAnimation {
                canSendMessage = false
            }
            let result = await askTutor(modelInput: lesson.memory)
            let resultContent = result["content"] ?? "Error occured while loading the answer"
            lesson.memory.append(["role" : "assistant", "content" : resultContent])
            let tutorMessage = Message(text: resultContent, isSentByUser: false)
            withAnimation {
                lesson.conversation.append(tutorMessage)
            }
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
            lesson.memory.append(["role" : "user", "content" : command])
            let result = await askTutor(modelInput: lesson.memory)
            let resultContent = result["content"] ?? "Error occured while loading the answer"
            lesson.memory.append(["role" : "assistant", "content" : resultContent])
            let tutorMessage = Message(text: resultContent, isSentByUser: false)
            withAnimation {
                lesson.conversation.append(tutorMessage)
            }
            withAnimation {
                canSendMessage = true
            }
        }
    }
    
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        VStack {
            HStack {
                if message.isSentByUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("YOU")
                        .bold()
                        .font(.system(size: 14))
                        .foregroundColor(Color(grey))
                    Spacer()
                } else {
                    Image(systemName: "book.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("TUTOR")
                        .bold()
                        .font(.system(size: 14))
                        .foregroundColor(Color(grey))
                    Spacer()
                }
            }
            HStack {
                Text(message.text)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 16))
                    .offset(x: 12)
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        
    }
}

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        LessonView()
    }
}
