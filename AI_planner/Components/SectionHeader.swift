//
//  SectionHeader.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.secondaryTeal)
            
            Text(title)
                .font(AppTheme.Typography.headlineSmall)
                .foregroundColor(AppTheme.primaryDeepIndigo)
            
            Spacer()
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        SectionHeader(title: "Schedule", icon: "clock.fill")
        SectionHeader(title: "To Do", icon: "checklist")
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.bgPrimary)
}
