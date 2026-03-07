//
//  LoadingScreen.swift
//  AI_planner
//
//  Created by AI Assistant on 3/5/26.
//

import SwiftUI

struct LoadingScreen: View {
    @State private var progress: Double = 0
    @State private var loadingTextIndex = 0
    @State private var beaverOffset: CGFloat = 0
    @State private var sparkleRotation: Double = 0
    
    let loadingTexts = [
        "Waking up the beaver...",
        "Organizing your schedule...",
        "Preparing smart suggestions...",
        "Almost ready..."
    ]
    
    let onComplete: () -> Void
    let minimumLoadTime: Double = 2.5
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    AppTheme.bgSecondary,
                    AppTheme.bgPrimary,
                    AppTheme.bgTertiary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RadialGradient(
                    colors: [
                        AppTheme.accentGold.opacity(0.14),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: 240
                )
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Beaver Logo with animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(AppTheme.accentGold.opacity(0.18))
                        .frame(width: 150, height: 150)
                        .blur(radius: 24)
                        .scaleEffect(1 + sin(progress * .pi) * 0.2)

                    Circle()
                        .fill(AppTheme.bgElevated.opacity(0.92))
                        .frame(width: 128, height: 128)

                    Circle()
                        .stroke(AppTheme.borderColor.opacity(0.8), lineWidth: 1)
                        .frame(width: 128, height: 128)
                    
                    // Beaver emoji with bounce
                    Image("beaver-loading")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 82, height: 82)
                        .offset(y: beaverOffset)
                        .rotationEffect(.degrees(sin(Double(beaverOffset) * 0.5) * 5))
                    
                    // Sparkles
                    HStack(spacing: 40) {
                        Text("✨")
                            .font(.title2)
                            .rotationEffect(.degrees(sparkleRotation))
                            .opacity(0.6 + sin(progress * 4) * 0.4)
                        
                        Spacer().frame(width: 80)
                        
                        Text("✨")
                            .font(.title2)
                            .rotationEffect(.degrees(-sparkleRotation))
                            .opacity(0.6 + cos(progress * 4) * 0.4)
                    }
                }
                .frame(height: 120)
                
                // App Name
                Text("Beaver Planner")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryDeepIndigo)
                
                // Tagline
                Text("Your smart schedule buddy")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer().frame(height: 20)
                
                // Loading text with fade transition
                Text(loadingTexts[loadingTextIndex])
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.primaryDeepIndigo)
                    .id(loadingTextIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .animation(.easeInOut(duration: 0.3), value: loadingTextIndex)
                
                // Progress bar
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.borderColor.opacity(0.65))
                                .frame(height: 8)
                            
                            // Fill with gradient
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.accentGold,
                                            AppTheme.secondaryTeal,
                                            AppTheme.primaryDeepIndigo
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 8)
                                .animation(.easeOut(duration: 0.2), value: progress)
                        }
                    }
                    .frame(width: 240, height: 8)
                    
                    // Percentage
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(AppTheme.textTertiary)
                }
                
                Spacer()
                
                // Footer quote
                Text("\"Busy beavers build smart\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.bottom, 32)
            }
            .padding()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Beaver bounce animation
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            beaverOffset = -8
        }
        
        // Sparkle rotation
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }
        
        // Progress animation
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if progress < 1.0 {
                // Non-linear progress for realism
                let increment = Double.random(in: 0.01...0.04)
                progress = min(progress + increment, 1.0)
            } else {
                timer.invalidate()
            }
        }
        
        // Text cycling
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
            if progress < 1.0 {
                loadingTextIndex = (loadingTextIndex + 1) % loadingTexts.count
            } else {
                timer.invalidate()
            }
        }
        
        // Completion callback
        DispatchQueue.main.asyncAfter(deadline: .now() + minimumLoadTime) {
            withAnimation(.easeInOut(duration: 0.5)) {
                onComplete()
            }
        }
    }
}

#Preview {
    LoadingScreen(onComplete: {})
}
