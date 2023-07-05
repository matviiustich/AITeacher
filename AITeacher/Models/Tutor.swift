//
//  AIModel.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import Foundation

func loadPrompt() -> String {
    let path = Bundle.main.path(forResource: "prompt", ofType: "txt")
    do {
        return try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    } catch {
        fatalError("Error occured while extracting prompt")
    }
}

func askTutor(modelInput: [[String: String]]) async -> [String: String] {
    let path = Bundle.main.path(forResource: "OPENAI_API_KEY", ofType: "txt")
    var apiKey: String = ""
    do {
        apiKey = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    } catch {
        fatalError("Error occured while extracting API key")
    }
    
    let urlString = "https://api.openai.com/v1/chat/completions"
    let url = URL(string: urlString)!
    
    let headers = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(apiKey)"
    ]
    
    let parameters: [String: Any] = [
        "model": "gpt-3.5-turbo", /* gpt-3.5-turbo */
        "messages": modelInput,
        "temperature": 0.7
    ]
    
    var assistantMessage: [String: String] = [:]  // Initialize with empty dictionary
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let choices = json?["choices"] as? [[String: Any]],
               let tutorMessage = choices[0]["message"] as? [String: String],
               let tutorContent = tutorMessage["content"] {
                print("AI Tutor:", tutorContent)
                
                assistantMessage = [
                    "role": "assistant",
                    "content": tutorContent
                ]
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
        
    } catch {
        print("Error: \(error)")
    }
    
    return assistantMessage
}

func createChapters(lesson: String, depthLevel: String, using createChapter: @MainActor (String) -> ()) async {
    
    let messages: [[String: String]] = [
        ["role": "system", "content": loadPrompt()],
        ["role": "system", "content": "Create a plan for the \(lesson) lesson with a depth level of \(depthLevel), by listing the topics that need to be covered to learn the subject. CALL createChapter function for EVERY topic listed"]
    ]
    
    let functions: [[String: Any]] = [
        [
            "name": "createChapter",
            "description": "Creates lessons based on the given topics",
            "parameters": [
                "type": "object",
                "properties": [
                    "topics": [
                        "type": "array",
                        "items": [
                            "type": "string"
                        ],
                        "description": "The lesson topics, e.g. Linear algebra"
                    ] as [String : Any]
                ],
                "required": ["topics"]
            ] as [String : Any]
        ]
    ]
    
    let path = Bundle.main.path(forResource: "OPENAI_API_KEY", ofType: "txt")
    var apiKey: String = ""
    do {
        apiKey = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    } catch {
        fatalError("Error occured while extracting API key")
    }
    
    let urlString = "https://api.openai.com/v1/chat/completions"
    let url = URL(string: urlString)!
    
    let headers = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(apiKey)"
    ]
    
    let parameters: [String: Any] = [
        "model": "gpt-3.5-turbo-0613",
        "messages": messages,
        "functions": functions,
        "function_call": "auto"
    ]
    
    var funcContent: [String]?
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let choices = json?["choices"] as? [[String: Any]],
               let tutorMessage = choices[0]["message"] as? [String: Any], let functions = tutorMessage["function_call"] as? [String: Any], let arguments = functions["arguments"] as? String, let jsonData = arguments.data(using: .utf8) {
                
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode([String: [String]].self, from: jsonData)
                    funcContent = data["topics"]
                } catch {
                    fatalError("Error decoding JSON: \(error)")
                }
                
                
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
        
    } catch {
        print("Error: \(error)")
    }
    
    if let funcContent = funcContent {
        for arg in funcContent {
            await createChapter(arg)
        }
        
    }
}
