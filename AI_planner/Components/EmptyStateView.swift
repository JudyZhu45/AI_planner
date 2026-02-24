//
//  EmptyStateView.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var buttonTitle: String? = nil
    var onAction: (() -> Void)? = nil
    var compact: Bool = false
    
    var body: some View {
        VStack(spacing: compact ? AppTheme.Spacing.md : AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: compact ? 36 : 48, weight: .light))
                .foregroundColor(AppTheme.secondaryTeal.opacity(0.4))
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(title)
                    .font(compact ? AppTheme.Typography.bodyMedium : AppTheme.Typography.headlineSmall)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(subtitle)
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let buttonTitle, let onAction {
                Button(action: onAction) {
                    Text(buttonTitle)
                        .font(AppTheme.Typography.titleMedium)
                        .foregroundColor(AppTheme.textInverse)
                        .padding(.horizontal, AppTheme.Spacing.xxl)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.secondaryTeal)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                }
                .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, compact ? AppTheme.Spacing.lg : AppTheme.Spacing.huge)
    }
}

#Preview {
    VStack(spacing: 32) {
        EmptyStateView(
            icon: "sparkles",
            title: "No tasks for today",
            subtitle: "Tap the + button to add an event or task",
            buttonTitle: "Add Event",
            onAction: {}
        )
        
        Divider()
        
        EmptyStateView(
            icon: "calendar.badge.plus",
            title: "No events scheduled",
            subtitle: "Plan your day by adding events",
            compact: true
        )
    }
    .padding()
}
