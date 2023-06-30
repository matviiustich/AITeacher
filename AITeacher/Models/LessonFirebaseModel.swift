//
//  LessonFirebaseModel.swift
//  AITeacher
//
//  Created by Александр Устич on 30.06.2023.
//

import Foundation
import FirebaseFirestore

//class LessonFirebaseModel {
//    let db = Firestore.firestore()
//
//    func storeLesson(_ lesson: Lesson) {
//        do {
//            let lessonData = try JSONEncoder().encode(lesson)
//            let lessonDict = try JSONSerialization.jsonObject(with: lessonData, options: []) as? [String: Any]
//
//            guard let dict = lessonDict else {
//                return
//            }
//
//            db.collection("lessons").addDocument(data: dict) { error in
//                if let error = error {
//                    print("Error storing lesson: \(error.localizedDescription)")
//                } else {
//                    print("Lesson stored successfully.")
//                }
//            }
//        } catch {
//            print("Error encoding lesson: \(error.localizedDescription)")
//        }
//    }
//
//    func retrieveLessons(completion: @escaping ([Lesson]) -> Void) {
//        db.collection("lessons").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error retrieving lessons: \(error.localizedDescription)")
//                completion([])
//                return
//            }
//
//            var lessons: [Lesson] = []
//
//            for document in snapshot?.documents ?? [] {
//                do {
//                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
//                    let lesson = try JSONDecoder().decode(Lesson.self, from: jsonData)
//                    lessons.append(lesson)
//                } catch {
//                    print("Error decoding lesson: \(error.localizedDescription)")
//                }
//            }
//
//            completion(lessons)
//        }
//    }
//
//    func updateLesson(_ lesson: Lesson) {
//        do {
//            let lessonData = try JSONEncoder().encode(lesson)
//            let lessonDict = try JSONSerialization.jsonObject(with: lessonData, options: []) as? [String: Any]
//
//            guard let dict = lessonDict else {
//                return
//            }
//
//            if let lessonId = lesson.id.uuidString {
//                db.collection("lessons").document(lessonId).setData(dict) { error in
//                    if let error = error {
//                        print("Error updating lesson: \(error.localizedDescription)")
//                    } else {
//                        print("Lesson updated successfully.")
//                    }
//                }
//            }
//        } catch {
//            print("Error encoding lesson: \(error.localizedDescription)")
//        }
//    }
//
//    func deleteLesson(_ lesson: Lesson) {
//        if let lessonId = lesson.id.uuidString {
//            db.collection("lessons").document(lessonId).delete { error in
//                if let error = error {
//                    print("Error deleting lesson: \(error.localizedDescription)")
//                } else {
//                    print("Lesson deleted successfully.")
//                }
//            }
//        }
//    }
//}

class LessonFirebaseModel: ObservableObject {
    let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @Published var lessons: [Lesson] = []
    
    func storeLesson(_ lesson: Lesson) {
        do {
            let lessonData = try JSONEncoder().encode(lesson)
            let lessonDict = try JSONSerialization.jsonObject(with: lessonData, options: []) as? [String: Any]
            
            guard let dict = lessonDict else {
                return
            }
            
            db.collection("lessons").addDocument(data: dict) { error in
                if let error = error {
                    print("Error storing lesson: \(error.localizedDescription)")
                } else {
                    print("Lesson stored successfully.")
                }
            }
        } catch {
            print("Error encoding lesson: \(error.localizedDescription)")
        }
    }
    
    func retrieveLessons(completion: @escaping ([Lesson]) -> Void) {
        db.collection("lessons").getDocuments { snapshot, error in
            if let error = error {
                print("Error retrieving lessons: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var lessons: [Lesson] = []
            
            for document in snapshot?.documents ?? [] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    let lesson = try JSONDecoder().decode(Lesson.self, from: jsonData)
                    lessons.append(lesson)
                } catch {
                    print("Error decoding lesson: \(error.localizedDescription)")
                }
            }
            
            completion(lessons)
        }
    }
    
    func updateLesson(_ lesson: Lesson) {
        do {
            let lessonData = try! JSONEncoder().encode(lesson)
            let lessonDict = try! JSONSerialization.jsonObject(with: lessonData, options: []) as? [String: Any]
            
            guard let dict = lessonDict else {
                return
            }
            
            let lessonId = lesson.id.uuidString
            db.collection("lessons").document(lessonId).setData(dict) { error in
                if let error = error {
                    print("Error updating lesson: \(error.localizedDescription)")
                } else {
                    print("Lesson updated successfully.")
                }
            }
        }
    }
    
    func deleteLesson(_ lesson: Lesson) {
        let lessonId = lesson.id.uuidString
        db.collection("lessons").document(lessonId).delete { error in
            if let error = error {
                print("Error deleting lesson: \(error.localizedDescription)")
            } else {
                print("Lesson deleted successfully.")
            }
        }
    }
    
    func startListening() {
        stopListening()  // Stop any existing listener
        
        listener = db.collection("lessons").addSnapshotListener { snapshot, error in
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
    
}


