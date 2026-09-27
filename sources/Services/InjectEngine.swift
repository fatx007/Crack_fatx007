//
//  InjectEngine.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed Injection Engine & Container Resolver (_TtC10Fatx0072R7).
//

import Foundation
import UIKit

public class InjectEngine {
    public static let shared = InjectEngine()
    
    private let fileManager = FileManager.default
    private var backups: [FFGame: [InjectedFileReplacement]] = [:]
    public private(set) var activeInjections: Set<FFGame> = []
    
    private let containerSearchPaths = [
        "/var/mobile/Containers/Data/Application",
        "/private/var/mobile/Containers/Data/Application"
    ]
    
    private init() {}
    
    // MARK: - Container Resolution via MobileContainerManager Metadata
    public func resolveGameContainer(for game: FFGame) -> ContainerResolution {
        AppLog.shared.log("[MCM] Searching container for \(game.bundleID)")
        
        #if targetEnvironment(simulator)
        return .bridgeUnavailable
        #endif
        
        for basePath in containerSearchPaths {
            guard fileManager.fileExists(atPath: basePath) else { continue }
            
            do {
                let uuidFolders = try fileManager.contentsOfDirectory(atPath: basePath)
                for folder in uuidFolders {
                    let folderURL = URL(fileURLWithPath: basePath).appendingPathComponent(folder)
                    let metaPlistURL = folderURL.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
                    
                    if fileManager.fileExists(atPath: metaPlistURL.path) {
                        do {
                            let metaData = try Data(contentsOf: metaPlistURL)
                            if let plist = try PropertyListSerialization.propertyList(from: metaData, format: nil) as? [String: Any],
                               let identifier = plist["MCMMetadataIdentifier"] as? String {
                                if identifier == game.bundleID {
                                    AppLog.shared.log("[MCM] container resolved: \(folderURL.path)")
                                    return .resolved(folderURL)
                                }
                            }
                        } catch {
                            // Container file read permission denied
                            continue
                        }
                    }
                }
            } catch {
                return .accessDenied(error.localizedDescription)
            }
        }
        
        AppLog.shared.log("[KRW] metadata scan found no matching container for \(game.bundleID)")
        return .notFound
    }
    
    // MARK: - Injection Execution
    public func inject(game: FFGame, configuration: F4) async throws {
        AppLog.shared.log("[RUNTIME] Preparing injection for \(game.displayName)")
        
        // 1. Resolve Game Container
        let resolution = resolveGameContainer(for: game)
        let containerURL: URL
        switch resolution {
        case .resolved(let url):
            containerURL = url
        case .notFound:
            throw FFInjectError.containerNotFound
        case .accessDenied(let reason):
            throw FFInjectError.containerAccessDenied(reason)
        case .bridgeUnavailable:
            throw FFInjectError.containerBridgeUnavailable
        }
        
        // 2. Locate Injection Payload
        guard let patchURL = Bundle.main.url(forResource: "Assembly-CSharp-patch", withExtension: "bytes") ??
              Bundle.main.url(forResource: "Assembly-CSharp-patch", withExtension: "") else {
            AppLog.shared.log("[-] Missing runtime resource: Assembly-CSharp-patch.bytes")
            throw FFInjectError.fileUnavailable("Assembly-CSharp-patch.bytes")
        }
        
        let patchData = try Data(contentsOf: patchURL)
        
        // 3. Target destination path in Game Container
        // Unity IFix patches deploy into Documents or Library/Caches
        let targetDir = containerURL.appendingPathComponent("Documents")
        let targetPatchFile = targetDir.appendingPathComponent("Assembly-CSharp-patch.bytes")
        let configOutputFile = targetDir.appendingPathComponent(".ffxc_runtime.json")
        
        try fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true)
        
        // 4. Backup existing file if present
        var gameBackups: [InjectedFileReplacement] = []
        if fileManager.fileExists(atPath: targetPatchFile.path) {
            let existingData = try Data(contentsOf: targetPatchFile)
            let existingAttrs = (try? fileManager.attributesOfItem(atPath: targetPatchFile.path)) ?? [:]
            gameBackups.append(InjectedFileReplacement(url: targetPatchFile, originalData: existingData, originalAttributes: existingAttrs))
        }
        self.backups[game] = gameBackups
        
        // 5. Install Payload & Config
        try patchData.write(to: targetPatchFile, options: .atomic)
        
        // Write feature options configuration
        let configPayload: [String: Any] = [
            "game": game.rawValue,
            "testCodePatch": true,
            "radius": configuration.radius,
            "aimbotRadius": configuration.aimbotRadius,
            "h0": configuration.h0,
            "a0": configuration.a0,
            "fastReloadPercent": configuration.fastReloadPercent,
            "fastFireLevel": configuration.fastFireLevel,
            "espColor": configuration.espColor,
            "espThickness": configuration.espThickness,
            "aimFovMode": configuration.aimFovMode,
            "selected": Array(configuration.selected),
            "timestamp": Date().timeIntervalSince1970
        ]
        let configData = try JSONSerialization.data(withJSONObject: configPayload, options: .prettyPrinted)
        try configData.write(to: configOutputFile, options: .atomic)
        
        AppLog.shared.log("[RUNTIME] payload installed successfully")
        self.activeInjections.insert(game)
        
        // 6. Launch Game
        await launchGame(game: game)
    }
    
    // MARK: - Un-inject & Cleanup
    public func uninject(game: FFGame) async throws {
        AppLog.shared.log("[RUNTIME] Initiating un-inject for \(game.displayName)")
        
        let resolution = resolveGameContainer(for: game)
        if case .resolved(let containerURL) = resolution {
            let targetDir = containerURL.appendingPathComponent("Documents")
            let targetPatchFile = targetDir.appendingPathComponent("Assembly-CSharp-patch.bytes")
            let configOutputFile = targetDir.appendingPathComponent(".ffxc_runtime.json")
            
            // Restore backup if available
            if let saved = backups[game], let first = saved.first {
                try? first.originalData.write(to: first.url, options: .atomic)
                AppLog.shared.log("[WIPE] configuration restore applied")
            } else {
                // Otherwise delete installed patch
                if fileManager.fileExists(atPath: targetPatchFile.path) {
                    try? fileManager.removeItem(at: targetPatchFile)
                }
            }
            
            if fileManager.fileExists(atPath: configOutputFile.path) {
                try? fileManager.removeItem(at: configOutputFile)
            }
            
            AppLog.shared.log("[WIPE] protected payload cleanup completed")
            AppLog.shared.log("[RUNTIME] un-inject cleanup completed")
        }
        
        self.backups.removeValue(forKey: game)
        self.activeInjections.remove(game)
    }
    
    // MARK: - Launch Game
    @MainActor
    private func launchGame(game: FFGame) {
        AppLog.shared.log("[LAUNCH] cold start requested for \(game.bundleID)")
        
        // Try direct URL scheme if registered
        let schemes = [
            "freefire://",
            "freefiremax://",
            "com.dts.freefireth://",
            "com.dts.freefiremax://"
        ]
        
        for scheme in schemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        AppLog.shared.log("[LAUNCH] completed via scheme: \(scheme)")
                    }
                }
                return
            }
        }
        
        AppLog.shared.log("[LAUNCH] complete. (Please switch to game manually if not auto-launched)")
    }
}
