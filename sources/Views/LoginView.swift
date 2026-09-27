//
//  LoginView.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed License Key Validation Screen (_TtC10Fatx0079LoginView).
//

import SwiftUI

public struct LoginView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var language: LanguageStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var keyInput: String = ""
    @State private var isValidating: Bool = false
    @State private var errorMessage: String? = nil
    @State private var didLoad: Bool = false
    @State private var presentedLanguageSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 28) {
            // Language selector button at top right
            HStack {
                Spacer()
                Button(action: { presentedLanguageSheet = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                        Text(language.current.displayName)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(16)
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            Spacer()
            
            // App Branding & Title
            FFXCBrandMark(compact: false)
                .scaleEffect(didLoad ? 1.0 : 0.95)
                .opacity(didLoad ? 1.0 : 0.0)
            
            // Key Entry Card
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(language.string(for: "key_placeholder"))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(Color.cyan)
                            .frame(width: 24)
                        
                        TextField("FFXC-XXXX-XXXXX", text: $keyInput)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                        
                        if !keyInput.isEmpty {
                            Button(action: { keyInput = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(white: 0.12))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Error message banner
                if let err = errorMessage ?? session.revocationMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(8)
                }
                
                // Validate Button
                Button(action: handleValidate) {
                    HStack(spacing: 8) {
                        if isValidating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            Text(language.string(for: "validating"))
                                .font(.system(size: 15, weight: .bold))
                        } else {
                            Image(systemName: "checkmark.shield.fill")
                            Text(language.string(for: "validate"))
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .shadow(color: Color.cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(keyInput.trimmingCharacters(in: .whitespaces).isEmpty || isValidating)
                .opacity((keyInput.trimmingCharacters(in: .whitespaces).isEmpty || isValidating) ? 0.6 : 1.0)
            }
            .padding(24)
            .background(Color(white: 0.08).opacity(0.95))
            .cornerRadius(18)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Device footer details
            VStack(spacing: 4) {
                Text("\(language.string(for: "device")): \(UIDevice.current.name) • \(language.string(for: "ios_version")): \(UIDevice.current.systemVersion)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.gray.opacity(0.8))
                Text("Build 67 • MobileHouseArrest Edition")
                    .font(.system(size: 10, weight: .light, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $presentedLanguageSheet) {
            LanguagePickerView()
                .environmentObject(language)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                didLoad = true
            }
        }
    }
    
    private func handleValidate() {
        guard !keyInput.isEmpty else { return }
        isValidating = true
        errorMessage = nil
        
        Task {
            let success = await session.login(with: keyInput)
            await MainActor.run {
                isValidating = false
                if !success {
                    errorMessage = language.string(for: "key_invalid")
                }
            }
        }
    }
}
