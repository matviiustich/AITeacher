//
//  MessageView.swift
//  AITeacher
//
//  Created by Александр Устич on 05.07.2023.
//

import SwiftUI

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
//                        .foregroundColor(Color(grey))
                    Spacer()
                } else {
                    Image(systemName: "book.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("TUTOR")
                        .bold()
                        .font(.system(size: 14))
//                        .foregroundColor(Color(grey))
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
