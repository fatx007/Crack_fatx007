//
//  ComponentViews.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed UI Components, Styles, and Controls.
//

import SwiftUI

// MARK: - Persistent Bottom Inject Bar
public struct BottomInjectBar: View {
    public let title: String
    public let isWorking: Bool
    public let isEnabled: Bool
    public let isInjected: Bool
    public let inject: () -> Void
    public let uninject: () -> Void
    public let reset: () -> Void
    
    public init(
        title: String,
        isWorking: Bool,
        isEnabled: Bool,
        isInjected: Bool,
        inject: @escaping () -> Void,
        uninject: @escaping () -> Void,
        reset: @escaping () -> Void
    ) {
        self.title = title
        self.isWorking = isWorking
        self.isEnabled = isEnabled
        self.isInjected = isInjected
        self.inject = inject
        self.uninject = uninject
        self.reset = reset
    }
    
    public var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                if isInjected {
                    Button(action: uninject) {
                        HStack {
                            Image(systemName: "xmark.shield.fill")
                            Text("UNINJECT")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: inject) {
                        HStack {
                            if isWorking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                Text("Injecting...")
                                    .font(.system(size: 15, weight: .bold))
                            } else {
                                Image(systemName: "bolt.shield.fill")
                                Text(title)
                                    .font(.system(size: 15, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            isEnabled ?
                            LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(isEnabled ? .black : .white.opacity(0.5))
                        .cornerRadius(12)
                        .shadow(color: isEnabled ? Color.cyan.opacity(0.35) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isEnabled || isWorking)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Color(white: 0.08)
                    .opacity(0.96)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

// MARK: - Game Target Selector
public struct GameSelector: View {
    @Binding public var selectedGame: FFGame
    public let onSelect: (FFGame) -> Void
    
    public init(selectedGame: Binding<FFGame>, onSelect: @escaping (FFGame) -> Void) {
        self._selectedGame = selectedGame
        self.onSelect = onSelect
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(FFGame.allCases) { game in
                Button(action: {
                    selectedGame = game
                    onSelect(game)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: game == .freeFireMax ? "crown.fill" : "flame.fill")
                            .foregroundColor(selectedGame == game ? .black : .cyan)
                        Text(game.displayName)
                            .font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedGame == game ?
                        LinearGradient(colors: [Color.cyan, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.03)], startPoint: .top, endPoint: .bottom)
                    )
                    .foregroundColor(selectedGame == game ? .black : .white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedGame == game ? Color.cyan : Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
            }
        }
    }
}

// MARK: - Feature Toggle Row
public struct FeatureRow: View {
    public let option: F1
    @Binding public var isOn: Bool
    
    public init(option: F1, isOn: Binding<Bool>) {
        self.option = option
        self._isOn = isOn
    }
    
    public var body: some View {
        HStack {
            if let sym = option.symbol {
                Image(systemName: sym)
                    .foregroundColor(isOn ? .cyan : .gray)
                    .frame(width: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(option.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                if let sub = option.subtitle {
                    Text(sub)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
        }
    }
}

// MARK: - ESP Color & Swatches Control
public struct ESPColorRow: View {
    @Binding public var color: String
    @Binding public var thickness: Double
    
    public let names = [
        "Cyan", "Green", "Lime", "Yellow", "Orange", "Red",
        "Purple", "Mint", "Sky", "Rose", "Amber", "White",
        "Brown", "Emerald", "Ice", "Pure White"
    ]
    
    public let swatches: [String: Color] = [
        "Cyan": .cyan, "Green": .green, "Lime": Color(red: 0.7, green: 1.0, blue: 0.0),
        "Yellow": .yellow, "Orange": .orange, "Red": .red,
        "Purple": .purple, "Mint": Color(red: 0.4, green: 0.9, blue: 0.7),
        "Sky": Color(red: 0.3, green: 0.7, blue: 1.0), "Rose": Color(red: 1.0, green: 0.4, blue: 0.6),
        "Amber": Color(red: 1.0, green: 0.75, blue: 0.0), "White": .white,
        "Brown": Color(red: 0.6, green: 0.4, blue: 0.2), "Emerald": Color(red: 0.0, green: 0.8, blue: 0.4),
        "Ice": Color(red: 0.7, green: 0.9, blue: 1.0), "Pure White": .white
    ]
    
    public init(color: Binding<String>, thickness: Binding<Double>) {
        self._color = color
        self._thickness = thickness
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ESP Color: \(color)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Circle()
                    .fill(swatches[color] ?? .cyan)
                    .frame(width: 14, height: 14)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(names, id: \.self) { n in
                        Button(action: { color = n }) {
                            Circle()
                                .fill(swatches[n] ?? .white)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: color == n ? 2.5 : 0)
                                )
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            
            HStack {
                Text("Thickness: \(String(format: "%.1f", thickness))px")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Slider(value: $thickness, in: 1.0...5.0, step: 0.5)
                    .accentColor(.cyan)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }
}

// MARK: - Aim Sliders & Target Rows
public struct FOVRadiusRow: View {
    public let title: String
    @Binding public var radius: Double
    public let policy: F2
    
    public init(title: String, radius: Binding<Double>, policy: F2) {
        self.title = title
        self._radius = radius
        self.policy = policy
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(radius)) px")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            Slider(value: $radius, in: policy.min...policy.max, step: policy.step)
                .accentColor(.cyan)
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }
}

public struct HeadshotRateRow: View {
    @Binding public var value: Double
    public let policy: F2
    
    public init(value: Binding<Double>, policy: F2) {
        self._value = value
        self.policy = policy
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Headshot Rate")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(value))%")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            Slider(value: $value, in: policy.min...policy.max, step: policy.step)
                .accentColor(.cyan)
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }
}

public struct AimTargetRow: View {
    @Binding public var target: String
    private let targets = ["head", "neck", "chest", "pelvis"]
    
    public init(target: Binding<String>) {
        self._target = target
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Aim Target")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            Picker("Aim Target", selection: $target) {
                ForEach(targets, id: \.self) { t in
                    Text(t.capitalized).tag(t)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }
}

public struct AimFovModeRow: View {
    @Binding public var mode: String
    private let modes = ["firing", "always", "off"]
    
    public init(mode: Binding<String>) {
        self._mode = mode
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Aim FOV Trigger")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            Picker("FOV Trigger", selection: $mode) {
                ForEach(modes, id: \.self) { m in
                    Text(m.capitalized).tag(m)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }
}

public struct FastReloadRow: View {
    @Binding public var percent: Double
    
    public init(percent: Binding<Double>) {
        self._percent = percent
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Reload Speedup")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("+\(Int(percent))%")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            Slider(value: $percent, in: 10.0...80.0, step: 5.0)
                .accentColor(.cyan)
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }
}

public struct FastFireRow: View {
    @Binding public var level: Int
    
    public init(level: Binding<Int>) {
        self._level = level
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Rapid Fire Level")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("Lv \(level)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            Picker("Level", selection: $level) {
                Text("Level 1").tag(1)
                Text("Level 2").tag(2)
                Text("Level 3").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }
}

// MARK: - Visual Background Backdrop
public struct FFXCBackdrop: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black
            
            // Radial accent glows
            RadialGradient(
                gradient: Gradient(colors: [Color.cyan.opacity(0.18), Color.clear]),
                center: .topTrailing,
                startRadius: 20,
                endRadius: 360
            )
            
            RadialGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.12), Color.clear]),
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 400
            )
        }
    }
}

// MARK: - App Brand Logo & Title
public struct FFXCBrandMark: View {
    public let compact: Bool
    
    public init(compact: Bool = false) {
        self.compact = compact
    }
    
    public var body: some View {
        HStack(spacing: compact ? 8 : 12) {
            ZStack {
                RoundedRectangle(cornerRadius: compact ? 8 : 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: compact ? 30 : 54, height: compact ? 30 : 54)
                
                Image(systemName: "cross.fill")
                    .font(.system(size: compact ? 14 : 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("FATX007")
                    .font(.system(size: compact ? 15 : 22, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                if !compact {
                    Text("FFXC PRIVATE EDITION • 3.7.33")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }
            }
        }
    }
}

// MARK: - Live Engine Log View
public struct FFXCLogView: View {
    @ObservedObject private var logManager = AppLog.shared
    @State private var copied: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ENGINE CONSOLE")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = logManager.entries.joined(separator: "\n")
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                }) {
                    Text(copied ? "COPIED" : "COPY LOGS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(logManager.entries.enumerated()), id: \.offset) { idx, entry in
                            Text(entry)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.green.opacity(0.9))
                                .id(idx)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .onChange(of: logManager.entries.count) { count in
                    if count > 0 {
                        proxy.scrollTo(count - 1)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Language Picker View
public struct LanguagePickerView: View {
    @EnvironmentObject private var language: LanguageStore
    @Environment(\.presentationMode) private var presentationMode
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List(FFLanguage.allCases) { lang in
                Button(action: {
                    language.current = lang
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(lang.displayName)
                            .foregroundColor(.white)
                        Spacer()
                        if language.current == lang {
                            Image(systemName: "checkmark")
                                .foregroundColor(.cyan)
                        }
                    }
                }
            }
            .navigationTitle(language.string(for: "select_language"))
            .navigationBarItems(trailing: Button(language.string(for: "cancel")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
