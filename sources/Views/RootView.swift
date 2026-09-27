//
//  RootView.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed Root Navigation & ScenePhase Controller (_TtC10Fatx0078RootView).
//

import SwiftUI

public struct RootView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var language: LanguageStore
    @Environment(\.scenePhase) private var scenePhase
    
    public init() {}
    
    public var body: some View {
        ZStack {
            FFXCBackdrop()
                .ignoresSafeArea()
            
            if session.state.isValid {
                MainMenuView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.state.isValid)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active && session.state.isValid {
                Task {
                    _ = await AuthService.shared.revalidate()
                }
            }
        }
    }
}
