//
//  AppLog.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed log manager (_TtC10Fatx0076AppLog).
//

import Foundation
import Combine

public class AppLog: ObservableObject {
    public static let shared = AppLog()
    
    @Published public private(set) var entries: [String] = []
    private let lock = NSLock()
    private let maxEntries = 500
    
    private init() {
        log("[BOOT] Fatx007 runtime initialized")
    }
    
    public func log(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let formatted = "[\(timestamp)] \(message)"
        
        lock.lock()
        defer { lock.unlock() }
        
        DispatchQueue.main.async {
            self.entries.append(formatted)
            if self.entries.count > self.maxEntries {
                self.entries.removeFirst(self.entries.count - self.maxEntries)
            }
        }
        #if DEBUG
        print(formatted)
        #endif
    }
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        DispatchQueue.main.async {
            self.entries.removeAll()
        }
    }
}
