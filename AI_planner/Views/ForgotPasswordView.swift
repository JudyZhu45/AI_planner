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
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    } else if showResetForm {
                        // Code + New Password form
                        VStack(spacing: AppTheme.Spacing.lg) {
                            AuthFormField(
                                label: "Verification Code",
                                icon: "number",
                                placeholder: "Enter 6-digit code",
                                text: $confirmationCode,
                                keyboardType: .numberPad
                            )
                            
                            AuthFormField(
                                label: "New Password",
                                icon: "lock.fill",
                                placeholder: "Min. 8 characters",
                                text: $newPassword,
                                isSecure: true,
                                textContentType: .newPassword
                            )
                            
                            if let error = authManager.errorMessage {
                                AuthErrorMessage(message: error)
                            }
                            
                            AuthPrimaryButton(
                                title: "Reset Password",
                                isLoading: authManager.isLoading,
                                isDisabled: confirmationCode.count < 6 || newPassword.isEmpty
                            ) {
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
                            }
                        }
                        .padding(AppTheme.Spacing.xxl)
                        .background(AppTheme.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
                        .shadow(color: AppTheme.shadowColor, radius: 16, x: 0, y: 8)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    } else {
                        // Email form
                        VStack(spacing: AppTheme.Spacing.lg) {
                            AuthFormField(
                                label: "Email",
                                icon: "envelope.fill",
                                placeholder: "your@email.com",
                                text: $email,
                                textContentType: .emailAddress,
                                keyboardType: .emailAddress
                            )
                            
                            if let error = authManager.errorMessage {
                                AuthErrorMessage(message: error)
                            }
                            
                            AuthPrimaryButton(
                                title: "Send Reset Code",
                                isLoading: authManager.isLoading,
                                isDisabled: email.isEmpty
                            ) {
                                Task {
                                    let needsCode = await authManager.resetPassword(for: email)
                                    if needsCode {
                                        showResetForm = true
                                    }
                                }
                            }
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
