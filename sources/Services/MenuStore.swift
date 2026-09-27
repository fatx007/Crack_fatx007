//
//  MenuStore.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed Menu & Features Store (_TtC10Fatx0072M4).
//

import SwiftUI
import Combine

public class MenuStore: ObservableObject {
    public static let shared = MenuStore()
    
    private let selectedGameKey = "ffxc.selectedGame"
    private let defaults = UserDefaults.standard
    
    @Published public var selectedGame: FFGame {
        didSet {
            defaults.set(selectedGame.rawValue, forKey: selectedGameKey)
            updateInjectState()
        }
    }
    
    @Published public var catalog: F3? = nil
    @Published public var configurations: [FFGame: F4] = [:]
    @Published public var injectStates: [FFGame: InjectState] = [:]
    
    private init() {
        if let saved = defaults.string(forKey: selectedGameKey),
           let game = FFGame(rawValue: saved) {
            self.selectedGame = game
        } else {
            self.selectedGame = .freeFire
        }
        
        // Initialize default configs for both games
        self.configurations[.freeFire] = loadConfiguration(for: .freeFire)
        self.configurations[.freeFireMax] = loadConfiguration(for: .freeFireMax)
        
        self.catalog = Self.createBuiltinCatalog()
        updateInjectState()
    }
    
    public var currentConfig: F4 {
        get {
            configurations[selectedGame] ?? F4.default
        }
        set {
            configurations[selectedGame] = newValue
            saveConfiguration(newValue, for: selectedGame)
        }
    }
    
    public var currentInjectState: InjectState {
        injectStates[selectedGame] ?? .ready
    }
    
    public func updateInjectState() {
        let game = selectedGame
        injectStates[game] = .checking
        
        Task { @MainActor in
            let res = InjectEngine.shared.resolveGameContainer(for: game)
            switch res {
            case .resolved:
                self.injectStates[game] = .ready
            case .notFound:
                self.injectStates[game] = .gameNotInstalled(bundleID: game.bundleID)
            case .accessDenied(let err):
                self.injectStates[game] = .containerAccessDenied(detail: err)
            case .bridgeUnavailable:
                self.injectStates[game] = .containerBridgeUnavailable
            }
        }
    }
    
    // MARK: - Persistence
    private func configKey(for game: FFGame) -> String {
        "ffxc.config.\(game.rawValue)"
    }
    
    private func loadConfiguration(for game: FFGame) -> F4 {
        if let data = defaults.data(forKey: configKey(for: game)),
           let decoded = try? JSONDecoder().decode(F4.self, from: data) {
            return decoded
        }
        return F4.default
    }
    
    public func saveConfiguration(_ config: F4, for game: FFGame) {
        if let encoded = try? JSONEncoder().encode(config) {
            defaults.set(encoded, forKey: configKey(for: game))
        }
    }
    
    public func resetSelectedGame() {
        currentConfig = F4.default
        AppLog.shared.log("[CONFIG] Reset settings for \(selectedGame.displayName)")
    }
    
    // MARK: - Builtin Catalog
    private static func createBuiltinCatalog() -> F3 {
        let sections = [
            F0(id: "sec_esp", title: "ESP Visuals"),
            F0(id: "sec_aimbot", title: "Aimbot & Assistance"),
            F0(id: "sec_memory", title: "Weapon & Performance")
        ]
        
        let options = [
            F1(id: "esp_box", section: "sec_esp", title: "ESP Box 2D", subtitle: "Draw 2D bounding boxes around enemies", symbol: "square", radius: nil, h0: nil, a0: nil, exclusiveGroup: nil, fastReload: nil, fastFire: nil, colorControl: true, aimFovMode: nil, aimbotFov: nil),
            F1(id: "esp_line", section: "sec_esp", title: "ESP Snaplines", subtitle: "Draw direction lines to targets", symbol: "line.diagonal", radius: nil, h0: nil, a0: nil, exclusiveGroup: nil, fastReload: nil, fastFire: nil, colorControl: true, aimFovMode: nil, aimbotFov: nil),
            F1(id: "esp_skeleton", section: "sec_esp", title: "ESP Skeleton", subtitle: "Display bone structure", symbol: "figure.walk", radius: nil, h0: nil, a0: nil, exclusiveGroup: nil, fastReload: nil, fastFire: nil, colorControl: true, aimFovMode: nil, aimbotFov: nil),
            F1(id: "esp_distance", section: "sec_esp", title: "ESP Distance & Name", subtitle: "Player distance and player nickname", symbol: "textformat", radius: nil, h0: nil, a0: nil, exclusiveGroup: nil, fastReload: nil, fastFire: nil, colorControl: nil, aimFovMode: nil, aimbotFov: nil),
            F1(id: "aim_auto", section: "sec_aimbot", title: "Auto Aim Assist", subtitle: "Smooth crosshair lock", symbol: "scope", radius: F2(min: 20, max: 300, step: 5, initial: 120), h0: nil, a0: true, exclusiveGroup: nil, fastReload: nil, fastFire: nil, colorControl: nil, aimFovMode: true, aimbotFov: true),
            F1(id: "aim_headshot", section: "sec_aimbot", title: "Headshot Rate Modifier", subtitle: "Adjust head hit probability", symbol: "target", radius: nil, h0: F2(min: 0, max: 100, step: 5, initial: 75), a0: nil, exclusiveGroup: nil, fastReload: nil, fastFire: nil, colorControl: nil, aimFovMode: nil, aimbotFov: nil),
            F1(id: "mem_fastreload", section: "sec_memory", title: "Fast Reload", subtitle: "Shorten magazine reload time", symbol: "bolt.fill", radius: nil, h0: nil, a0: nil, exclusiveGroup: nil, fastReload: true, fastFire: nil, colorControl: nil, aimFovMode: nil, aimbotFov: nil),
            F1(id: "mem_fastfire", section: "sec_memory", title: "Rapid Fire Rate", subtitle: "Increase bullet output per second", symbol: "flame.fill", radius: nil, h0: nil, a0: nil, exclusiveGroup: nil, fastReload: nil, fastFire: true, colorControl: nil, aimFovMode: nil, aimbotFov: nil)
        ]
        
        return F3(
            version: "3.7.33",
            sections: sections,
            options: options,
            radius: F2(min: 20, max: 300, step: 5, initial: 120),
            h0: F2(min: 0, max: 100, step: 5, initial: 50)
        )
    }
}
