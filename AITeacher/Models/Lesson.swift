//
//  Lesson.swift
//  AITeacher
//
//  Created by Александр Устич on 27.06.2023.
//

import Foundation

struct Message: Identifiable, Hashable, Codable {
    let id: String
    var text: String
    let isSentByUser: Bool
}

struct Chapter: Identifiable, Hashable, Codable {
    let id: String
    
    let title: String
    var conversation: [Message]
    var memory: [[String: String]]
}

struct Lesson: Identifiable, Hashable, Codable {
    
    let id: String
    
    let title: String
    let lastUpdated: Date
    var chapters: [Chapter]
}

struct UserPreferences: Codable {
    var language: String
    var learningStyle: String
    var communicationStyle: String
    var toneStyle: String
    var reasoningFramework: String
}
