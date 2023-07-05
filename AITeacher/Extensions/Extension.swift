//
//  UIApplication+Extension.swift
//  AITeacher
//
//  Created by Александр Устич on 27.06.2023.
//

import SwiftUI


func hapticsFeedback() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

extension View {
    func dismissKeyboard() -> some View {
        modifier(DismissKeyboardModifier())
    }
}

extension ScrollViewProxy {
    func scrollToLastMessage(messages: [Message]) {
        DispatchQueue.main.async {
            if let lastMessage = messages.last {
                withAnimation {
                    self.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
}

struct DismissKeyboardModifier: ViewModifier {
    @State var startPos : CGPoint = .zero
    @State var isSwipping = true
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) // dismisses the keyboard
            }
    }
}
