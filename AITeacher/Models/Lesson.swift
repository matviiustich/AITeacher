//
//  Lesson.swift
//  AITeacher
//
//  Created by Александр Устич on 27.06.2023.
//

import Foundation

struct Lesson: Identifiable {
    let id = UUID()
    
    let title: String
    var conversation: [[String: String]]
}
