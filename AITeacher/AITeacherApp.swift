//
//  AITeacherApp.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        print(db)
        
        return true
    }
}

@main
struct AITeacherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AuthenticatedView {
                    
                    VStack {
                        Text("Welcome to the Classroom!")
                            .font(.title)
                            .bold()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } content: {
                    ContentView()
                }
            }
        }
    }
    
}
