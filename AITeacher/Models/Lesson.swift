//
//  Lesson.swift
//  AITeacher
//
//  Created by Александр Устич on 27.06.2023.
//

import Foundation

struct Message: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isSentByUser: Bool
}

struct Lesson: Identifiable, Hashable {
    let id = UUID()
    
    let title: String
    var conversation: [Message]
    var memory: [[String: String]]
    
    // Lesson configuration
    var depthLevel: Int?
    var learningStyle: String?
    var communicationStyle: String?
    var toneStyle: String?
    var reasoningFramework: String?
    
}
