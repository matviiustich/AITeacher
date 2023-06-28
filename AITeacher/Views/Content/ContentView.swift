//
//  ContentView.swift
//  AITeacher
//
//  Created by Александр Устич on 06.06.2023.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    var body: some View {
        TabView {
            LessonsTabView()
                .tabItem {
                    Label("Lessons", systemImage: "book")
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

