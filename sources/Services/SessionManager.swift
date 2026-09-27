//
//  SessionManager.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed Session Manager (_TtC10Fatx0072S5).
//

import SwiftUI
import Combine

public class SessionManager: ObservableObject {
    @Published public var state: AuthState = .empty
    @Published public var revocationMessage: String? = nil
    @Published public var languageSelected: Bool = true
    @Published public var isDarkMode: Bool = true
    @Published public var isOnline: Bool = true
    @Published public var networkErrorCount: Int = 0
    @Published public var isRefreshing: Bool = false
    
    private var revalidationTask: Task<Void, Never>? = nil
    private var timerCancellable: AnyCancellable? = nil
    private let savedKeyStorageKey = "ffxc.saved_key"
    
    public init() {
        // Load saved key if present
        if let savedKey = UserDefaults.standard.string(forKey: savedKeyStorageKey), !savedKey.isEmpty {
            Task { @MainActor in
                await self.login(with: savedKey)
            }
        }
        
        // Listen for system auth notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAuthRevoked),
            name: NSNotification.Name("FFXCAuthorizationRevoked"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAuthRefreshed),
            name: NSNotification.Name("FFXCAuthorizationRefreshed"),
            object: nil
        )
        
        startHeartbeat()
    }
    
    deinit {
        revalidationTask?.cancel()
        timerCancellable?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    @MainActor
    public func login(with key: String) async -> Bool {
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            let res = try await AuthService.shared.validateKey(key)
            self.state = res
            self.isOnline = true
            self.revocationMessage = nil
            self.networkErrorCount = 0
            UserDefaults.standard.set(key, forKey: savedKeyStorageKey)
            AppLog.shared.log("[SESSION] User logged in with key: \(key)")
            return true
        } catch {
            self.revocationMessage = error.localizedDescription
            AppLog.shared.log("[SESSION] Login failed: \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    public func logout() {
        AuthService.shared.logout()
        self.state = .empty
        UserDefaults.standard.removeObject(forKey: savedKeyStorageKey)
        AppLog.shared.log("[SESSION] Logged out and session cleared")
    }
    
    private func startHeartbeat() {
        revalidationTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60 * 1_000_000_000) // Every 60s
                guard let self = self else { break }
                guard await self.isLoggedIn() else { continue }
                
                let res = await AuthService.shared.revalidate()
                await MainActor.run {
                    switch res {
                    case .valid:
                        self.isOnline = true
                        self.networkErrorCount = 0
                    case .revoked(let reason):
                        self.state = .empty
                        self.isOnline = false
                        self.revocationMessage = reason
                        AppLog.shared.log("[-] Heartbeat revoked: \(reason)")
                    case .networkError:
                        self.networkErrorCount += 1
                        if self.networkErrorCount > 3 {
                            self.isOnline = false
                        }
                        AppLog.shared.log("[AUTH] Heartbeat unavailable (attempt=\(self.networkErrorCount))")
                    }
                }
            }
        }
    }
    
    @objc private func handleAuthRevoked() {
        DispatchQueue.main.async {
            self.state = .empty
            self.isOnline = false
        }
    }
    
    @objc private func handleAuthRefreshed() {
        DispatchQueue.main.async {
            self.isOnline = true
        }
    }
    
    public func isLoggedIn() async -> Bool {
        return self.state.isValid
    }
    
    public var remainingTimeString: String {
        guard let exp = state.keyExpiresAt else {
            return state.keyExpiryRaw.isEmpty ? "Never" : state.keyExpiryRaw
        }
        let diff = exp.timeIntervalSince(Date())
        if diff <= 0 {
            return "Expired"
        }
        let days = Int(diff) / 86400
        let hours = (Int(diff) % 86400) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if days > 0 {
            return "\(days)d \(hours)h"
        }
        return "\(hours)h \(minutes)m"
    }
}
