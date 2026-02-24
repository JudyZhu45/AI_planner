//
//  AuthErrorMessage.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import SwiftUI

struct AuthErrorMessage: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(AppTheme.Typography.bodySmall)
            .foregroundColor(AppTheme.accentCoral)
            .multilineTextAlignment(.center)
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(AppTheme.accentCoral.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
    }
}

#Preview {
    AuthErrorMessage(message: "Invalid email or password. Please try again.")
        .padding()
}
