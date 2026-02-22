//
//  ForgotPasswordView.swift
//  AI_planner
//
//  Created by Judy459 on 2/22/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var newPassword = ""
    @State private var confirmationCode = ""
    @State private var showResetForm = false
    @State private var isResetComplete = false
    
    var body: some View {
        ZStack {
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xxxl) {
                    Spacer(minLength: 40)
                    
                    // Header
                    VStack(spacing: AppTheme.Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accentCoral.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "key.fill")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(AppTheme.accentCoral)
                        }
                        
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Text(isResetComplete ? "Password Reset!" : showResetForm ? "Reset Password" : "Forgot Password")
                                .font(AppTheme.Typography.displayMedium)
                                .foregroundColor(AppTheme.primaryDeepIndigo)
                            
                            Text(isResetComplete
                                 ? "You can now sign in with your new password."
                                 : showResetForm
                                 ? "Enter the code and your new password."
                                 : "Enter your email to receive a reset code.")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    if isResetComplete {
                        // Success
                        Button {
                            dismiss()
                        } label: {
                            Text("Back to Sign In")
                                .font(AppTheme.Typography.titleLarge)
                                .foregroundColor(.white)
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
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    } else if showResetForm {
                        // Code + New Password form
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Code field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                Text("Verification Code")
                                    .font(AppTheme.Typography.labelLarge)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack(spacing: AppTheme.Spacing.md) {
                                    Image(systemName: "number")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textTertiary)
                                    
                                    TextField("Enter 6-digit code", text: $confirmationCode)
                                        .keyboardType(.numberPad)
                                        .font(AppTheme.Typography.bodyLarge)
                                }
                                .padding(AppTheme.Spacing.lg)
                                .background(AppTheme.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                            }
                            
                            // New password field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                Text("New Password")
                                    .font(AppTheme.Typography.labelLarge)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack(spacing: AppTheme.Spacing.md) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textTertiary)
                                    
                                    SecureField("Min. 8 characters", text: $newPassword)
                                        .textContentType(.newPassword)
                                        .font(AppTheme.Typography.bodyLarge)
                                }
                                .padding(AppTheme.Spacing.lg)
                                .background(AppTheme.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                            }
                            
                            // Error message
                            if let error = authManager.errorMessage {
                                Text(error)
                                    .font(AppTheme.Typography.bodySmall)
                                    .foregroundColor(AppTheme.accentCoral)
                                    .multilineTextAlignment(.center)
                                    .padding(AppTheme.Spacing.md)
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.accentCoral.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                            }
                            
                            // Reset button
                            Button {
                                Task {
                                    let success = await authManager.confirmResetPassword(
                                        for: email,
                                        newPassword: newPassword,
                                        code: confirmationCode
                                    )
                                    if success {
                                        isResetComplete = true
                                    }
                                }
                            } label: {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("Reset Password")
                                        .font(AppTheme.Typography.titleLarge)
                                }
                                .foregroundColor(.white)
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
                            .disabled(confirmationCode.count < 6 || newPassword.isEmpty || authManager.isLoading)
                            .opacity(confirmationCode.count < 6 || newPassword.isEmpty ? 0.6 : 1)
                        }
                        .padding(AppTheme.Spacing.xxl)
                        .background(AppTheme.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
                        .shadow(color: AppTheme.shadowColor, radius: 16, x: 0, y: 8)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    } else {
                        // Email form
                        VStack(spacing: AppTheme.Spacing.lg) {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                Text("Email")
                                    .font(AppTheme.Typography.labelLarge)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack(spacing: AppTheme.Spacing.md) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textTertiary)
                                    
                                    TextField("your@email.com", text: $email)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .font(AppTheme.Typography.bodyLarge)
                                }
                                .padding(AppTheme.Spacing.lg)
                                .background(AppTheme.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                            }
                            
                            // Error message
                            if let error = authManager.errorMessage {
                                Text(error)
                                    .font(AppTheme.Typography.bodySmall)
                                    .foregroundColor(AppTheme.accentCoral)
                                    .multilineTextAlignment(.center)
                                    .padding(AppTheme.Spacing.md)
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.accentCoral.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                            }
                            
                            // Send Code button
                            Button {
                                Task {
                                    let needsCode = await authManager.resetPassword(for: email)
                                    if needsCode {
                                        showResetForm = true
                                    }
                                }
                            } label: {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("Send Reset Code")
                                        .font(AppTheme.Typography.titleLarge)
                                }
                                .foregroundColor(.white)
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
                            .disabled(email.isEmpty || authManager.isLoading)
                            .opacity(email.isEmpty ? 0.6 : 1)
                        }
                        .padding(AppTheme.Spacing.xxl)
                        .background(AppTheme.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
                        .shadow(color: AppTheme.shadowColor, radius: 16, x: 0, y: 8)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView(authManager: AuthManager())
    }
}
