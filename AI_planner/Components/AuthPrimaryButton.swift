//
//  AuthPrimaryButton.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import SwiftUI

struct AuthPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(AppTheme.textInverse)
                }
                Text(title)
                    .font(AppTheme.Typography.titleLarge)
            }
            .foregroundColor(AppTheme.textInverse)
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.lg)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.primaryDeepIndigo,
                        AppTheme.primaryDeepIndigo.opacity(0.85)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .shadow(color: AppTheme.primaryDeepIndigo.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthPrimaryButton(title: "Sign In", action: {})
        AuthPrimaryButton(title: "Loading...", isLoading: true, action: {})
        AuthPrimaryButton(title: "Disabled", isDisabled: true, action: {})
    }
    .padding()
}
