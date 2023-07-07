//
//  AIModel.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import Foundation
import OpenAI

enum NetworkingError: Error {
    case timeLimit
    case overload
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

func createChapters(lesson: String, depthLevel: String, language: String, using createChapter: @MainActor (String) -> ()) async throws {
    let functions = [
        ChatFunctionDeclaration(
            name: "createChapter",
            description: "Creates lessons based on the given topics",
            parameters:
                JSONSchema(
                    type: .object,
                    properties: [
                        "topics": .init(
                            type: .array,
                            description: "The lesson topics, e.g. Linear algebra", items: .init(type: .string)
                        ),
                        "unit": .init(type: .string, enumValues: ["celsius", "fahrenheit"])
                    ],
                    required: ["locations"]
                )
        )
    ]
    
    
    
    
    let query = ChatQuery(
        model: "gpt-3.5-turbo-0613",
        messages: [Chat(role: .system, content: loadPrompt()), Chat(role: .system, content: "Create a plan for the \(lesson) lesson in \(language) language with a depth level of \(depthLevel), by listing the topics that need to be covered to learn the subject. CALL createChapter function for ALL topics listed")],
        functions: functions
    )
    
    do {
        let result = try await openAI.chats(query: query)
        if let function = result.choices[0].message.functionCall {
            if function.name == "createChapter" && function.arguments != nil {
                let jsonString = function.arguments!

                guard let jsonData = jsonString.data(using: .utf8) else {
                    fatalError("Failed to convert string to data.")
                }

                do {
                    let decoder = JSONDecoder()
                    let dictionary = try decoder.decode([String: [String]].self, from: jsonData)
                    if dictionary["topics"] != nil {
                        for element in dictionary["topics"]! {
                            await createChapter(element)
                        }
                    }
                    print(dictionary)
                } catch {
                    fatalError("Failed to decode JSON: \(error)")
                }

            }
        }
    } catch {
        print("Error: \(error)")
                throw NetworkingError.timeLimit
    }
}
