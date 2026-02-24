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
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .fill(isSelected ? AppTheme.primaryDeepIndigo : AppTheme.bgTertiary)
                )
        }
    }
}

#Preview {
    HStack {
        FilterButton(title: "All", isSelected: true, action: {})
        FilterButton(title: "Active", isSelected: false, action: {})
    }
    .padding()
}
