//
//  FFXCApp.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed full Swift source code from Mach-O metadata
//

import SwiftUI

@main
struct FFXCApp: App {
    @StateObject private var session = SessionManager()
    @StateObject private var language = LanguageStore.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(language)
                .preferredColorScheme(.dark)
        }
    }
}
