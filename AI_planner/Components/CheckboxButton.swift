//
//  CheckboxButton.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct CheckboxButton: View {
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                action()
            }
        }) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isChecked ? AppTheme.secondaryTeal : AppTheme.textTertiary)
                .scaleEffect(isChecked ? 1.1 : 1.0)
        }
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
