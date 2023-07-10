//
//  AIModel.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import Foundation
import OpenAI

enum NetworkingError: Error {
    case tokenError(error: String)
}

func loadAPI() -> String {
    let path = Bundle.main.path(forResource: "OPENAI_API_KEY", ofType: "txt")
    do {
        return try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    } catch {
        fatalError("Error occured while extracting prompt")
    }
}

func loadPrompt() -> String {
    let path = Bundle.main.path(forResource: "prompt", ofType: "txt")
    do {
        return try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    } catch {
        fatalError("Error occured while extracting prompt")
    }
}

func memoryToChat(memory: [[String: String]]) -> [Chat] {
    var chat: [Chat] = []
    for el in memory {
        if el["role"] == "user" {
            chat.append(Chat(role: .user, content: el["content"]))
        } else if el["role"] == "system" {
            chat.append(Chat(role: .system, content: el["content"]))
        } else {
            chat.append(Chat(role: .assistant, content: el["content"]))
        }
    }
    return chat
}
