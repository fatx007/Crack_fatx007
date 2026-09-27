//
//  AuthService.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed Authentication Actor (_TtC10Fatx007P33_9ED085D451241BB0368B554FC8E2B3C72Q7).
//

import Foundation
import CryptoKit
import UIKit

public actor AuthService {
    public static let shared = AuthService()
    
    private let baseURL = URL(string: "http://localhost:8080/api")!
    private var state: AuthState = .empty
    private var sessionToken: String?
    private var isSessionLocked = false
    private var sessionWaiters: [CheckedContinuation<AuthState, Error>] = []
    
    // Server Public Key for Curve25519 signature verification
    private let serverPublicKeyHex = "3b94e0...ffxc"
    
    private init() {}
    
    // MARK: - Hardware Identification & Fingerprint
    public func getHWID() -> String {
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            return id
        }
        return "UNKNOWN_HWID"
    }
    
    public func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.isEmpty ? "iPhone" : identifier
    }
    
    // MARK: - Key Validation
    public func validateKey(_ key: String) async throws -> AuthState {
        AppLog.shared.log("[AUTH] Initiating key validation for \(key)")
        
        let endpoint = baseURL.appendingPathComponent("validate")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15.0
        
        let payload: [String: Any] = [
            "key": key.trimmingCharacters(in: .whitespacesAndNewlines),
            "hwid": getHWID(),
            "device": UIDevice.current.name,
            "ios_version": UIDevice.current.systemVersion,
            "model": getDeviceModel(),
            "bundle_id": Bundle.main.bundleIdentifier ?? "com.apple.mobile.MobileHouseArrest",
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "3.7.33"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FFInjectError.sessionInvalid
        }
        
        if httpResponse.statusCode != 200 {
            if let errResp = try? JSONDecoder().decode(E5.self, from: data) {
                AppLog.shared.log("[-] Validation failed: \(errResp.message)")
                throw NSError(domain: "AuthService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errResp.message])
            }
            throw FFInjectError.sessionInvalid
        }
        
        let authResponse = try JSONDecoder().decode(E1.self, from: data)
        guard authResponse.status.lowercased() == "success" || authResponse.status.lowercased() == "active" else {
            let msg = authResponse.message ?? "Invalid or expired key"
            AppLog.shared.log("[-] Status rejected: \(msg)")
            throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: msg])
        }
        
        // Parse expiration
        var expiresDate: Date? = nil
        if let expStr = authResponse.expiresAt {
            let iso = ISO8601DateFormatter()
            expiresDate = iso.date(from: expStr)
        }
        
        var sessionExpiresDate: Date? = nil
        if let sExp = authResponse.sessionExpiresAt {
            let iso = ISO8601DateFormatter()
            sessionExpiresDate = iso.date(from: sExp)
        } else if let ttl = authResponse.sessionTtl {
            sessionExpiresDate = Date().addingTimeInterval(TimeInterval(ttl))
        }
        
        let newState = AuthState(
            displayKey: key,
            plan: authResponse.plan ?? "VIP",
            keyExpiryRaw: authResponse.expiresAt ?? "Never",
            keyExpiresAt: expiresDate,
            authorization: authResponse.credential ?? authResponse.session,
            catalog: authResponse.catalog,
            session: authResponse.session,
            sessionExpiresAt: sessionExpiresDate
        )
        
        self.state = newState
        self.sessionToken = authResponse.session
        AppLog.shared.log("[AUTH] Key verified. Plan: \(newState.plan), Exp: \(newState.keyExpiryRaw)")
        NotificationCenter.default.post(name: NSNotification.Name("FFXCAuthorizationRefreshed"), object: nil)
        
        return newState
    }
    
    // MARK: - Heartbeat / Revalidation
    public func revalidate() async -> RevalidationResult {
        guard let token = sessionToken, !token.isEmpty else {
            return .revoked(reason: "No active session")
        }
        
        let endpoint = baseURL.appendingPathComponent("heartbeat")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10.0
        
        let body: [String: Any] = [
            "hwid": getHWID(),
            "timestamp": Int64(Date().timeIntervalSince1970)
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .networkError
            }
            
            if httpResponse.statusCode == 200 {
                return .valid
            } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                self.state = .empty
                self.sessionToken = nil
                NotificationCenter.default.post(name: NSNotification.Name("FFXCAuthorizationRevoked"), object: nil)
                return .revoked(reason: "License revoked or expired")
            } else {
                return .networkError
            }
        } catch {
            return .networkError
        }
    }
    
    public func logout() {
        self.state = .empty
        self.sessionToken = nil
        AppLog.shared.log("[AUTH] Logged out")
        NotificationCenter.default.post(name: NSNotification.Name("FFXCAuthorizationRevoked"), object: nil)
    }
    
    public func currentState() -> AuthState {
        return self.state
    }
}
