//
//  CheckboxButton.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI
import UIKit

struct CheckboxButton: View {
    let isChecked: Bool
    let action: () -> Void
    @State private var showBurst = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                action()
            }
            if !isChecked {
                showBurst = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showBurst = false
                }
            }
        }) {
            ZStack {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isChecked ? AppTheme.secondaryTeal : AppTheme.textTertiary)
                    .scaleEffect(isChecked ? 1.1 : 1.0)
                
                if showBurst {
                    Image("beaver-success")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .offset(y: -28)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .overlay(
            CompletionBurstView(isActive: $showBurst)
        )
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        CheckboxButton(isChecked: false, action: {})
        CheckboxButton(isChecked: true, action: {})
    }
    .padding(AppTheme.Spacing.xl)
    .background(AppTheme.bgPrimary)
}
