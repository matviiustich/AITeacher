//
//  LessonFirebaseModel.swift
//  AITeacher
//
//  Created by Александр Устич on 30.06.2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class LessonFirebaseModel: ObservableObject {
    let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @Published var lessons: [Lesson] = []
    @Published var preferences: UserPreferences?
    
    init() {
        initializeData()
        startListening()
    }
    
    private func initializeData() {
        Task.init {
            let retrievedLessons = await retrieveLessons()
            let retrievedPreferences = await retrieveUserPreferences()
            
            DispatchQueue.main.async {
                self.lessons = retrievedLessons
                self.preferences = retrievedPreferences ?? UserPreferences(language: "English", learningStyle: "Sensing", communicationStyle: "Stochastic", toneStyle: "Debate", reasoningFramework: "Deductive")
            }
        }
    }
    
    func createLesson(title: String, completion: @escaping (Lesson?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            completion(nil)
            return
        }
        
        do {
            let lessonID = UUID().uuidString
            print(lessonID)
            let lesson = Lesson(id: lessonID, title: title, lastUpdated: .now, chapters: [])
            let lessonData = try JSONEncoder().encode(lesson)
            let lessonDict = try JSONSerialization.jsonObject(with: lessonData, options: []) as? [String: Any]
            
            guard let dict = lessonDict else {
                completion(nil)
                return
            }
            
            let usersCollection = db.collection("users").document(currentUserID)
            usersCollection.collection("lessons").document(lessonID).setData(dict) { error in
                if let error = error {
                    print("Error storing lesson: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("Lesson stored successfully.")
                    completion(lesson)
                }
            }
            
        } catch {
            print("Error encoding lesson: \(error.localizedDescription)")
            completion(nil)
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


