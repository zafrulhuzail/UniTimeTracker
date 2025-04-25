//
//  UniTimeTrackerApp.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//

import SwiftUI

@main
struct UniTimeTrackerApp: App {
    @StateObject private var store = TimeStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
