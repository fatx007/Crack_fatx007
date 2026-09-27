//
//  FeatureSectionCard.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed Feature Section Card (_TtC10Fatx00718FeatureSectionCard).
//

import SwiftUI

public struct FeatureSectionCard: View {
    public let title: String
    public let options: [F1]
    @Binding public var config: F4?
    
    public init(title: String, options: [F1], config: Binding<F4?>) {
        self.title = title
        self.options = options
        self._config = config
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Title
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 2)
            
            // Feature Toggles and Sub-options
            ForEach(options) { opt in
                VStack(spacing: 12) {
                    FeatureRow(
                        option: opt,
                        isOn: Binding(
                            get: { config?.selected.contains(opt.id) ?? false },
                            set: { on in
                                if on {
                                    config?.selected.insert(opt.id)
                                } else {
                                    config?.selected.remove(opt.id)
                                }
                            }
                        )
                    )
                    
                    // Show extra controls if enabled
                    if config?.selected.contains(opt.id) == true {
                        VStack(spacing: 10) {
                            if opt.colorControl == true {
                                ESPColorRow(
                                    color: Binding(
                                        get: { config?.espColor ?? "Cyan" },
                                        set: { config?.espColor = $0 }
                                    ),
                                    thickness: Binding(
                                        get: { config?.espThickness ?? 2.0 },
                                        set: { config?.espThickness = $0 }
                                    )
                                )
                            }
                            
                            if opt.radius != nil || opt.aimbotFov == true {
                                FOVRadiusRow(
                                    title: "FOV Radius",
                                    radius: Binding(
                                        get: { config?.radius ?? 120.0 },
                                        set: { config?.radius = $0 }
                                    ),
                                    policy: opt.radius ?? F2(min: 20, max: 300, step: 5, initial: 120)
                                )
                            }
                            
                            if opt.h0 != nil {
                                HeadshotRateRow(
                                    value: Binding(
                                        get: { config?.h0 ?? 50.0 },
                                        set: { config?.h0 = $0 }
                                    ),
                                    policy: opt.h0 ?? F2(min: 0, max: 100, step: 5, initial: 50)
                                )
                            }
                            
                            if opt.a0 == true {
                                AimTargetRow(
                                    target: Binding(
                                        get: { config?.a0 ?? "head" },
                                        set: { config?.a0 = $0 }
                                    )
                                )
                            }
                            
                            if opt.aimFovMode == true {
                                AimFovModeRow(
                                    mode: Binding(
                                        get: { config?.aimFovMode ?? "firing" },
                                        set: { config?.aimFovMode = $0 }
                                    )
                                )
                            }
                            
                            if opt.fastReload == true {
                                FastReloadRow(
                                    percent: Binding(
                                        get: { config?.fastReloadPercent ?? 30.0 },
                                        set: { config?.fastReloadPercent = $0 }
                                    )
                                )
                            }
                            
                            if opt.fastFire == true {
                                FastFireRow(
                                    level: Binding(
                                        get: { config?.fastFireLevel ?? 1 },
                                        set: { config?.fastFireLevel = $0 }
                                    )
                                )
                            }
                        }
                        .padding(.leading, 12)
                        .padding(.top, 4)
                        .transition(.opacity)
                    }
                }
                .padding(.vertical, 6)
                
                if opt.id != options.last?.id {
                    Divider()
                        .background(Color.white.opacity(0.08))
                }
            }
        }
        .padding(16)
        .background(Color(white: 0.10))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}
