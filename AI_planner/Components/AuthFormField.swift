//
//  AuthFormField.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import SwiftUI

struct AuthFormField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var textContentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    var hint: String? = nil
    var showError: Bool = false
    var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Typography.labelLarge)
                .foregroundColor(AppTheme.textSecondary)
            
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textTertiary)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(textContentType)
                        .font(AppTheme.Typography.bodyLarge)
                } else {
                    TextField(placeholder, text: $text)
                        .textContentType(textContentType)
                        .autocapitalization(.none)
                        .keyboardType(keyboardType)
                        .font(AppTheme.Typography.bodyLarge)
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(showError ? AppTheme.accentCoral : AppTheme.borderColor, lineWidth: 1)
            )
            
            if showError, let errorMessage {
                Text(errorMessage)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundColor(AppTheme.accentCoral)
            } else if let hint {
                Text(hint)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthFormField(
            label: "Email",
            icon: "envelope.fill",
            placeholder: "your@email.com",
            text: .constant(""),
            keyboardType: .emailAddress
        )
        AuthFormField(
            label: "Password",
            icon: "lock.fill",
            placeholder: "Enter password",
            text: .constant(""),
            isSecure: true,
            hint: "Must include uppercase, lowercase, number & symbol"
        )
    }
    .padding()
}
