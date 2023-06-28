//
//  LessonView.swift
//  AITeacher
//
//  Created by Александр Устич on 28.06.2023.
//

import SwiftUI

struct LessonView: View {
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages) { message in
                        MessageView(message: message)
                    }
                }
            }
            .padding()

            HStack {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding(.trailing)
            }
            .padding(.bottom)
        }
        .navigationBarTitle("Chat", displayMode: .inline)
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }

        let newMessage = Message(text: messageText, isSentByUser: true)
        messages.append(newMessage)
        messageText = ""
    }
}

struct MessageView: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isSentByUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(ChatBubble(isFromCurrentUser: true))
            } else {
                Text(message.text)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .clipShape(ChatBubble(isFromCurrentUser: false))
                Spacer()
            }
        }
    }
}

struct ChatBubble: Shape {
    var isFromCurrentUser: Bool

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topLeft, .topRight, isFromCurrentUser ? .bottomLeft : .bottomRight],
                                cornerRadii: CGSize(width: 10, height: 10))
        return Path(path.cgPath)
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isSentByUser: Bool
}

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        LessonView()
    }
}
