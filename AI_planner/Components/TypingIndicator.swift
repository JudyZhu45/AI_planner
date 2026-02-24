//
//  TypingIndicator.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import SwiftUI

struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.md) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(AppTheme.textTertiary)
                        .frame(width: 7, height: 7)
                        .offset(y: animating ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.bgTertiary)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.xl,
                    style: .continuous
                )
            )
            
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .onAppear {
            animating = true
        }
    }
}

#Preview {
    TypingIndicator()
        .padding()
        .background(AppTheme.bgPrimary)
}
