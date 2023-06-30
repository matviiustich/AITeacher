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
    let apiKey = "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"
    let urlString = "https://api.openai.com/v1/chat/completions"
    let url = URL(string: urlString)!
    
    let headers = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(apiKey)"
    ]
    
    let parameters: [String: Any] = [
        "model": "gpt-3.5-turbo",
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
