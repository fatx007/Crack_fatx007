//
//  DataModels.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed data models, enums, and network transfer objects.
//

import Foundation
import Security

// MARK: - Game Targets
public enum FFGame: String, CaseIterable, Identifiable, Codable {
    case freeFire = "com.dts.freefireth"
    case freeFireMax = "com.dts.freefiremax"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .freeFire: return "Free Fire"
        case .freeFireMax: return "Free Fire MAX"
        }
    }
    
    public var bundleID: String { rawValue }
}

// MARK: - Injection Status & Errors
public enum InjectState: Equatable {
    case ready
    case checking
    case injecting
    case unsupportedOS(version: String)
    case unsupportedHardware(model: String)
    case gameNotInstalled(bundleID: String)
    case containerNotFound
    case containerAccessDenied(detail: String)
    case containerBridgeUnavailable
    case failed(message: String)
    case unavailable
    case simulator
    
    public var title: String {
        switch self {
        case .ready: return "INJECT"
        case .checking: return "Checking..."
        case .injecting: return "Injecting..."
        case .unsupportedOS: return "OS Not Supported"
        case .unsupportedHardware: return "Device Not Supported"
        case .gameNotInstalled: return "Game Not Installed"
        case .containerNotFound: return "Container Not Found"
        case .containerAccessDenied: return "Access Denied"
        case .containerBridgeUnavailable: return "Bridge Unavailable"
        case .failed: return "Failed"
        case .unavailable: return "UNAVAILABLE"
        case .simulator: return "Simulator Not Supported"
        }
    }
    
    public var isActionable: Bool {
        self == .ready
    }
}

public enum FFInjectError: Error, LocalizedError {
    case fileUnavailable(String)
    case writeFailed(String)
    case gameNotInstalled(bundleID: String)
    case containerAccessDenied(String)
    case containerNotFound
    case containerBridgeUnavailable
    case processResetUnavailable
    case launchFailed
    case sessionInvalid
    case integrityFailed
    
    public var errorDescription: String? {
        switch self {
        case .fileUnavailable(let f): return "Required runtime file unavailable: \(f)"
        case .writeFailed(let reason): return "Write failed: \(reason)"
        case .gameNotInstalled(let bid): return "The selected game (\(bid)) is not installed."
        case .containerAccessDenied(let det): return "Game container access denied: \(det)"
        case .containerNotFound: return "Game container not found. Tap Inject to retry."
        case .containerBridgeUnavailable: return "Private container access is unavailable in this installation environment."
        case .processResetUnavailable: return "Game process reset is unavailable."
        case .launchFailed: return "Game launch request failed."
        case .sessionInvalid: return "Session invalid or expired. Re-authenticate."
        case .integrityFailed: return "Runtime patch integrity check failed."
        }
    }
}

public enum DeviceSupportResult {
    case supported
    case unsupportedOS(version: String)
    case unsupportedHardware(model: String)
    case simulator
}

public enum SecureStoreError: Error {
    case status(OSStatus)
    case encoding
}

public enum ContainerResolution {
    case resolved(URL)
    case notFound
    case accessDenied(String)
    case bridgeUnavailable
}

public enum F9: Error {
    case missingResource
    case invalidNeutral
    case integrityMismatch
}

// MARK: - Catalog & Feature Models (F0 - F5, B6)

/// Catalog Section Definition (F0)
public struct F0: Identifiable, Codable {
    public let id: String
    public let title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

/// Catalog Option Definition (F1)
public struct F1: Identifiable, Codable {
    public let id: String
    public let section: String
    public let title: String
    public let subtitle: String?
    public let symbol: String?
    public let radius: F2?
    public let h0: F2?              // Headshot numeric range policy
    public let a0: Bool?            // Aimbot target option
    public let exclusiveGroup: String?
    public let fastReload: Bool?
    public let fastFire: Bool?
    public let colorControl: Bool?
    public let aimFovMode: Bool?
    public let aimbotFov: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, section, title, subtitle, symbol, radius, h0, a0
        case exclusiveGroup, fastReload, fastFire, colorControl, aimFovMode, aimbotFov
    }
}

/// Slider / Numeric Parameter Range (F2)
public struct F2: Codable {
    public let min: Double
    public let max: Double
    public let step: Double
    public let initial: Double
    
    enum CodingKeys: String, CodingKey {
        case min, max, step, initial
    }
}

/// Full Feature Catalog (F3)
public struct F3: Codable {
    public let version: String
    public let sections: [F0]
    public let options: [F1]
    public let radius: F2?
    public let h0: F2?
    
    enum CodingKeys: String, CodingKey {
        case version, sections, options, radius, h0
    }
}

/// Active Feature Configuration for Injection (F4)
public struct F4: Codable {
    public var selected: Set<String>
    public var radius: Double
    public var aimbotRadius: Double
    public var h0: Double           // Headshot rate %
    public var a0: String           // Aim target (e.g. "head", "neck", "body")
    public var fastReloadPercent: Double
    public var fastFireLevel: Int
    public var espColor: String
    public var espThickness: Double
    public var aimFovMode: String   // "always", "firing", "off"
    
    enum CodingKeys: String, CodingKey {
        case selected, radius, aimbotRadius, h0, a0
        case fastReloadPercent, fastFireLevel, espColor, espThickness, aimFovMode
    }
    
    public static var `default`: F4 {
        F4(
            selected: [],
            radius: 120.0,
            aimbotRadius: 80.0,
            h0: 50.0,
            a0: "head",
            fastReloadPercent: 30.0,
            fastFireLevel: 1,
            espColor: "Cyan",
            espThickness: 2.0,
            aimFovMode: "firing"
        )
    }
}

/// Game Configuration (F5) - Persisted per game target
public struct F5: Codable {
    public var game: FFGame
    public var selected: Set<String>
    public var radius: Double
    public var aimbotRadius: Double
    public var headshot: Double
    public var aimTarget: String
    public var fastReloadPercent: Double
    public var fastFireLevel: Int
    public var espColor: String
    public var espThickness: Double
    public var aimFovMode: String
    
    public init(game: FFGame, from config: F4) {
        self.game = game
        self.selected = config.selected
        self.radius = config.radius
        self.aimbotRadius = config.aimbotRadius
        self.headshot = config.h0
        self.aimTarget = config.a0
        self.fastReloadPercent = config.fastReloadPercent
        self.fastFireLevel = config.fastFireLevel
        self.espColor = config.espColor
        self.espThickness = config.espThickness
        self.aimFovMode = config.aimFovMode
    }
}

/// Deployment Snapshot (B6)
public struct B6: Codable {
    public let game: FFGame
    public let selection: Set<String>
    public let authorization: String
}

// MARK: - Client Device Info & Security Policy (L0, P4)

/// Client Hardware & Key Info (L0)
public struct L0: Codable {
    public let displayKey: String
    public let plan: String
    public let expiryDate: String
    public let expiresAt: Date?
    public let deviceName: String
    public let hwid: String
    public let iOSVersion: String
    public let iPhoneModel: String
}

/// Security Policy & Hashes (P4)
public struct P4: Codable {
    public let neutralSHA256: String
    public let patchSHA256: String
    public let executableDigest: String
    public let protocolVersion: String
    public let leaseSeconds: Int
    public let minimumBuild: Int
    public let securitySchema: Int
    public let heartbeatSeconds: Int
    public let maxNetworkErrors: Int
    public let k3: Int
    public let k4: Int
    public let k5: Int
    public let verifiedAt: Date
    public let validUntil: Date
}

// MARK: - Auth State & DTOs (State, E0 - E5)

public struct AuthState: Codable {
    public var displayKey: String
    public var plan: String
    public var keyExpiryRaw: String
    public var keyExpiresAt: Date?
    public var authorization: String?
    public var catalog: F3?
    public var session: String?
    public var sessionExpiresAt: Date?
    
    public var isValid: Bool {
        authorization != nil && (sessionExpiresAt == nil || sessionExpiresAt! > Date())
    }
    
    public static var empty: AuthState {
        AuthState(
            displayKey: "",
            plan: "",
            keyExpiryRaw: "",
            keyExpiresAt: nil,
            authorization: nil,
            catalog: nil,
            session: nil,
            sessionExpiresAt: nil
        )
    }
}

/// Envelope with cryptographic signature (E0)
public struct E0: Codable {
    public let data: String
    public let ts: Int64
    public let sig: String
}

/// Primary Auth Response (E1)
public struct E1: Codable {
    public let status: String
    public let message: String?
    public let plan: String?
    public let expiresAt: String?
    public let metadata: [String: String]?
    public let session: String?
    public let sessionTtl: Int?
    public let sessionExpiresAt: String?
    public let catalog: F3?
    public let deployment: [String: String]?
    public let command: String?
    public let credential: String?
    public let licenseLabel: String?
    
    enum CodingKeys: String, CodingKey {
        case status, message, plan, expiresAt, metadata, session
        case sessionTtl, sessionExpiresAt, catalog, deployment, command, credential, licenseLabel
    }
}

public struct E2: Codable {
    public let id: String
}

public struct E3: Codable {
    public let artifact: String
    public let state: String
    public let aux: String
    public let unitMask: Int
    public let mac: String
    public let k17: String?
    public let k18: String?
    
    enum CodingKeys: String, CodingKey {
        case artifact, state, aux, unitMask, mac, k17, k18
    }
}

/// Heartbeat payload (E4)
public struct E4: Codable {
    public let sequence: Int
    public let state: String
    public let aux: String
    public let leaseSeconds: Int
    public let mac: String
    public let k17: String?
    public let k18: String?
    
    enum CodingKeys: String, CodingKey {
        case sequence, state, aux, leaseSeconds, mac, k17, k18
    }
}

/// Error response (E5)
public struct E5: Codable {
    public let error: String
    public let message: String
}

// MARK: - Revalidation & Licensing Enums (L1, L3)
public enum RevalidationResult {
    case valid
    case revoked(reason: String)
    case networkError
}

public enum L1: String, Codable {
    case revoked
    case deleted
    case expired
    case deviceMismatch
    case invalid
    case server
    case network
    case malformedResponse
    case invalidSignature
    case replayDetected
    case secureStorage
    case integrityFailed
}

public enum L3: String, Codable {
    case revoked
    case deleted
    case expired
    case deviceMismatch
    case networkError
    case invalid
}

// MARK: - Backup & Injection Records
public struct InjectedFileReplacement {
    public let url: URL
    public let originalData: Data
    public let originalAttributes: [FileAttributeKey: Any]
    
    public init(url: URL, originalData: Data, originalAttributes: [FileAttributeKey: Any]) {
        self.url = url
        self.originalData = originalData
        self.originalAttributes = originalAttributes
    }
}
