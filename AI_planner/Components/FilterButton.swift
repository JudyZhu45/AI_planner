//
//  FilterButton.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.labelLarge)
                .foregroundColor(isSelected ? AppTheme.textInverse : AppTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .fill(
                            isSelected
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [AppTheme.primaryDeepIndigo, AppTheme.accentGold],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                : AnyShapeStyle(AppTheme.bgElevated)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .stroke(isSelected ? Color.white.opacity(0.12) : AppTheme.borderColor.opacity(0.9), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        FilterButton(title: "All", isSelected: true, action: {})
        FilterButton(title: "Active", isSelected: false, action: {})
    }
    .padding()
}
