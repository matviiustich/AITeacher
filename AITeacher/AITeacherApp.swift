//
//  AITeacherApp.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import SwiftUI

@main
struct AITeacherApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
