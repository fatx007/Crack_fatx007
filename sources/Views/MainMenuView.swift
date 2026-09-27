//
//  MainMenuView.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed Main Menu, Navigation & Dashboard Screen (_TtC10Fatx00711MainMenuView).
//

import SwiftUI
import Combine

public struct MainMenuView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var language: LanguageStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @StateObject private var menuStore = MenuStore.shared
    @State private var authorizationOnline: Bool = true
    @State private var integrityHealthy: Bool = true
    @State private var showLogoutAlert: Bool = false
    @State private var now: Date = Date()
    @State private var presentedSheet: Bool = false
    @State private var selectedTab: Int = 0 // 0: Features, 1: Console, 2: Settings
    
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Navigation Header
            headerBar
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
            
            // MARK: - Target Game Selector
            GameSelector(
                selectedGame: $menuStore.selectedGame,
                onSelect: { game in
                    menuStore.selectedGame = game
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            // MARK: - Tab Segment Bar
            tabSegmentControl
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            
            // MARK: - Content Area
            TabView(selection: $selectedTab) {
                // Tab 0: Features & Cheats
                ScrollView {
                    VStack(spacing: 16) {
                        featureSections
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90) // clearance for BottomInjectBar
                }
                .tag(0)
                
                // Tab 1: Live Engine Log
                FFXCLogView()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                    .tag(1)
                
                // Tab 2: Settings & Info
                settingsTab
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // MARK: - Bottom Persistent Inject Bar
            BottomInjectBar(
                title: menuStore.currentInjectState.title,
                isWorking: menuStore.currentInjectState == .injecting,
                isEnabled: menuStore.currentInjectState.isActionable,
                isInjected: InjectEngine.shared.activeInjections.contains(menuStore.selectedGame),
                inject: handleInject,
                uninject: handleUninject,
                reset: { menuStore.resetSelectedGame() }
            )
        }
        .onReceive(timer) { input in
            self.now = input
            self.authorizationOnline = session.isOnline
        }
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text(language.string(for: "logout")),
                message: Text("Are you sure you want to log out of Fatx007?"),
                primaryButton: .destructive(Text(language.string(for: "logout"))) {
                    session.logout()
                },
                secondaryButton: .cancel(Text(language.string(for: "cancel")))
            )
        }
    }
    
    // MARK: - Subviews
    private var headerBar: some View {
        HStack(alignment: .center) {
            FFXCBrandMark(compact: true)
            
            Spacer()
            
            // License status pill
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(session.isOnline ? Color.green : Color.red)
                        .frame(width: 7, height: 7)
                    Text(session.isOnline ? language.string(for: "status_online") : language.string(for: "status_offline"))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(session.isOnline ? .green : .red)
                }
                
                Text("\(language.string(for: "expires")): \(session.remainingTimeString)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.06))
            .cornerRadius(8)
        }
    }
    
    private var tabSegmentControl: some View {
        HStack(spacing: 8) {
            tabButton(title: "Features", icon: "slider.horizontal.3", index: 0)
            tabButton(title: "Console", icon: "terminal.fill", index: 1)
            tabButton(title: "Settings", icon: "gearshape.fill", index: 2)
        }
        .padding(4)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
    
    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(selectedTab == index ? Color.cyan : Color.clear)
            .foregroundColor(selectedTab == index ? .black : .gray)
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private var featureSections: some View {
        if let cat = menuStore.catalog {
            ForEach(cat.sections) { sec in
                let sectionOptions = cat.options.filter { $0.section == sec.id }
                FeatureSectionCard(
                    title: sec.title,
                    options: sectionOptions,
                    config: Binding(
                        get: { menuStore.configurations[menuStore.selectedGame] ?? F4.default },
                        set: { menuStore.configurations[menuStore.selectedGame] = $0 }
                    )
                )
            }
        }
    }
    
    private var settingsTab: some View {
        VStack(spacing: 16) {
            // Language Picker
            VStack(alignment: .leading, spacing: 8) {
                Text(language.string(for: "select_language"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                
                ForEach(FFLanguage.allCases) { lang in
                    Button(action: { language.current = lang }) {
                        HStack {
                            Text(lang.displayName)
                                .foregroundColor(.white)
                            Spacer()
                            if language.current == lang {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.cyan)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color.white.opacity(language.current == lang ? 0.12 : 0.04))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            .background(Color(white: 0.10))
            .cornerRadius(14)
            
            // Actions
            VStack(spacing: 12) {
                Button(action: { menuStore.resetSelectedGame() }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text(language.string(for: "reset_settings"))
                        Spacer()
                    }
                    .foregroundColor(.orange)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                }
                
                Button(action: { showLogoutAlert = true }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text(language.string(for: "logout"))
                        Spacer()
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func handleInject() {
        Task {
            do {
                try await InjectEngine.shared.inject(
                    game: menuStore.selectedGame,
                    configuration: menuStore.currentConfig
                )
                menuStore.updateInjectState()
            } catch {
                AppLog.shared.log("[-] Injection failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleUninject() {
        Task {
            do {
                try await InjectEngine.shared.uninject(game: menuStore.selectedGame)
                menuStore.updateInjectState()
            } catch {
                AppLog.shared.log("[-] Un-inject failed: \(error.localizedDescription)")
            }
        }
    }
}
