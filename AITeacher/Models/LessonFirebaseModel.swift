//
//  LessonFirebaseModel.swift
//  AITeacher
//
//  Created by Александр Устич on 30.06.2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import OpenAI

@MainActor
class LessonFirebaseModel: ObservableObject {
    let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @Published var lessons: [Lesson] = []
    @Published var preferences: UserPreferences?
    
    func createLesson(title: String, depthLevel: Int) async throws {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            throw NetworkingError.tokenError(error: "No authenticated user found")
        }
        
        do {
            let lessonID = UUID().uuidString
            print(lessonID)
            let lesson = Lesson(id: lessonID, depthLevel: depthLevel, title: title, lastUpdated: .now, chapters: [])
            let lessonData = try JSONEncoder().encode(lesson)
            let lessonDict = try JSONSerialization.jsonObject(with: lessonData, options: []) as? [String: Any]
            
            guard let dict = lessonDict else {
                throw NetworkingError.tokenError(error: "Failed to create a dictionary")
            }
            
            let usersCollection = db.collection("users").document(currentUserID)
            do {
                try await usersCollection.collection("lessons").document(lessonID).setData(dict)
                try await createChapters(lesson: lesson)
            } catch {
            }
        } catch {
            print("Error encoding lesson: \(error.localizedDescription)")
        }
    }
    
    func createChapters(lesson: Lesson) async throws {
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
        
        self.preferences = await retrieveUserPreferences()
        
        
        let query = ChatQuery(
            model: "gpt-3.5-turbo-0613",
            messages: [Chat(role: .system, content: loadPrompt()), Chat(role: .system, content: "Create a plan for the \(lesson.title) lesson in \(self.preferences?.language ?? "English") language with a depth level of \(lesson.depthLevel), by listing the topics that need to be covered to learn the subject. CALL createChapter function for ALL topics listed")],
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
                        var updatedLesson = lesson
                        if dictionary["topics"] != nil {
                            for topic in dictionary["topics"]! {
                                let config = "Depth level is Level_\(lesson.depthLevel). Learning style is \(self.preferences?.learningStyle ?? "auto"). Communication style is \(self.preferences?.communicationStyle ?? "auto"). Tone style is \(self.preferences?.toneStyle ?? "auto"). Reasoning framework is \(self.preferences?.reasoningFramework ?? "auto")"
                                    updatedLesson.chapters.append(Chapter(id: UUID().uuidString, title: topic, conversation: [], memory: [["role" : "system", "content" : loadPrompt()], ["role" : "system", "content" : "This lesson is about \(topic)"], ["role" : "system", "content" : config]]))
                                self.updateLesson(updatedLesson)
//                                await createChapter(element)
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
            throw NetworkingError.tokenError(error: error.localizedDescription)
        }
    }
    
    func retrieveLessons() async -> [Lesson] {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return []
        }
        
        let usersCollection = db.collection("users").document(currentUserID)
        do {
            let snapshot = try await usersCollection.collection("lessons").order(by: "lastUpdated", descending: true).getDocuments()
            var lessons: [Lesson] = []
            
            for document in snapshot.documents {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    let lesson = try JSONDecoder().decode(Lesson.self, from: jsonData)
                    lessons.append(lesson)
                } catch {
                    print("Error decoding lesson: \(error.localizedDescription)")
                }
            }
            
            return lessons
        } catch {
            print("Error retrieving lessons: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func updateLesson(_ lesson: Lesson) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }
        
        do {
            let lessonData = try! JSONEncoder().encode(lesson)
            let lessonDict = try! JSONSerialization.jsonObject(with: lessonData, options: []) as? [String: Any]
            
            guard let dict = lessonDict else {
                return
            }
            
            let lessonId = lesson.id
            let usersCollection = db.collection("users").document(currentUserID)
            usersCollection.collection("lessons").document(lessonId).setData(dict) { error in
                if let error = error {
                    print("Error updating lesson: \(error.localizedDescription)")
                } else {
                    print("Lesson updated successfully.")
                }
            }
        }
    }
    
    func deleteLesson(_ lesson: Lesson) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }
        
        let lessonId = lesson.id
        let usersCollection = db.collection("users").document(currentUserID)
        usersCollection.collection("lessons").document(lessonId).delete { error in
            if let error = error {
                print("Error deleting lesson: \(error.localizedDescription)")
            } else {
                print("Lesson deleted successfully.")
            }
        }
    }
    
    
    func startListening() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }
        
        stopListening()
        
        let usersCollection = db.collection("users").document(currentUserID)
        listener = usersCollection.collection("lessons").order(by: "lastUpdated", descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening for lessons: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }
            
            self.lessons = documents.compactMap { document in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    let lesson = try JSONDecoder().decode(Lesson.self, from: jsonData)
                    return lesson
                } catch {
                    print("Error decoding lesson: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: Preferences
    func updateUserPreferences(language: String, learningStyle: String, communicationStyle: String, toneStyle: String, reasoningFramework: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }
        
        let preferences = [
            "language": language,
            "learningStyle": learningStyle,
            "communicationStyle": communicationStyle,
            "toneStyle": toneStyle,
            "reasoningFramework": reasoningFramework
        ]
        
        let usersCollection = db.collection("users").document(currentUserID)
        
        // Check if the user document exists
        usersCollection.getDocument { snapshot, error in
            if let error = error {
                print("Error retrieving user document: \(error.localizedDescription)")
                return
            }
            
            if snapshot?.exists == false {
                // User document doesn't exist, create it
                usersCollection.setData([:]) { error in
                    if let error = error {
                        print("Error creating user document: \(error.localizedDescription)")
                    } else {
                        print("User document created successfully.")
                        // Update the preferences after creating the document
                        usersCollection.updateData(preferences) { error in
                            if let error = error {
                                print("Error updating user preferences: \(error.localizedDescription)")
                            } else {
                                print("User preferences updated successfully.")
                            }
                        }
                    }
                }
            } else {
                // User document exists, update the preferences
                usersCollection.updateData(preferences) { error in
                    if let error = error {
                        print("Error updating user preferences: \(error.localizedDescription)")
                    } else {
                        print("User preferences updated successfully.")
                    }
                }
            }
        }
    }
    
    //    @MainActor
    func retrieveUserPreferences() async -> UserPreferences? {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return nil
        }
        
        let usersCollection = db.collection("users").document(currentUserID)
        
        do {
            let snapshot = try await usersCollection.getDocument()
            guard let userData = snapshot.data(),
                  let language = userData["language"] as? String,
                  let learningStyle = userData["learningStyle"] as? String,
                  let communicationStyle = userData["communicationStyle"] as? String,
                  let toneStyle = userData["toneStyle"] as? String,
                  let reasoningFramework = userData["reasoningFramework"] as? String
            else {
                return nil
            }
            
            let userPreferences = UserPreferences(language: language, learningStyle: learningStyle,
                                                  communicationStyle: communicationStyle,
                                                  toneStyle: toneStyle,
                                                  reasoningFramework: reasoningFramework)
            return userPreferences
        } catch {
            print("Error retrieving user preferences: \(error.localizedDescription)")
            return nil
        }
    }
    
}


