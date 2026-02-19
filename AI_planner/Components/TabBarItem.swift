//
//  TabBarItem.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? AppTheme.primaryDeepIndigo : AppTheme.textTertiary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(label)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundColor(isSelected ? AppTheme.primaryDeepIndigo : AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .transaction { transaction in
            transaction.animation = .easeInOut(duration: 0.2)
        }
    }
}

#Preview {
    HStack {
        TabBarItem(icon: "clock.fill", label: "Today", isSelected: true, action: {})
        TabBarItem(icon: "calendar.circle.fill", label: "Calendar", isSelected: false, action: {})
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.bgSecondary)
}
