//
//  CompletionParticleEffect.swift
//  AI_planner
//
//  Created by Judy459 on 3/3/26.
//

import SwiftUI

struct CompletionBurstView: View {
    @Binding var isActive: Bool
    private let particleCount = 8
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                CompletionParticle(
                    index: index,
                    total: particleCount,
                    isActive: isActive
                )
            }
        }
        .allowsHitTesting(false)
    }
}

struct CompletionParticle: View {
    let index: Int
    let total: Int
    let isActive: Bool
    
    @State private var opacity: Double = 0
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 0
    
    private var angle: Double {
        Double(index) / Double(total) * 2 * .pi
    }
    
    private var color: Color {
        [AppTheme.secondaryTeal, AppTheme.accentCoral, AppTheme.primaryDeepIndigo][index % 3]
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 4, height: 4)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(offset)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    // Reset
                    opacity = 0
                    offset = .zero
                    scale = 0
                    
                    // Animate burst outward
                    withAnimation(.easeOut(duration: 0.5)) {
                        let distance: CGFloat = 24
                        offset = CGSize(
                            width: cos(angle) * distance,
                            height: sin(angle) * distance
                        )
                        opacity = 1
                        scale = 1.5
                    }
                    
                    // Fade out
                    withAnimation(.easeIn(duration: 0.3).delay(0.3)) {
                        opacity = 0
                        scale = 0.5
                    }
                }
            }
    }
}
