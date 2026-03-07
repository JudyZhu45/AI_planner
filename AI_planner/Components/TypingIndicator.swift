//
//  TypingIndicator.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import SwiftUI

struct TypingIndicator: View {
    @State private var bouncing = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image("beaver-loading")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(bouncing ? -5 : 5))
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true),
                        value: bouncing
                    )
                
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(AppTheme.primaryDeepIndigo.opacity(0.4))
                            .frame(width: 5, height: 5)
                            .offset(y: bouncing ? -3 : 0)
                            .animation(
                                .easeInOut(duration: 0.4)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                                value: bouncing
                            )
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.bgElevated)
            .overlay(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.xl,
                    style: .continuous
                )
                .stroke(AppTheme.borderColor.opacity(0.8), lineWidth: 1)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.xl,
                    style: .continuous
                )
            )
            .shadow(color: AppTheme.Shadows.xs.color, radius: AppTheme.Shadows.xs.radius, x: AppTheme.Shadows.xs.x, y: AppTheme.Shadows.xs.y)
            
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .onAppear {
            bouncing = true
        }
    }
}

#Preview {
    TypingIndicator()
        .padding()
        .background(AppTheme.bgPrimary)
}
