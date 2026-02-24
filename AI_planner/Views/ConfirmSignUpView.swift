//
//  ConfirmSignUpView.swift
//  AI_planner
//
//  Created by Judy459 on 2/22/26.
//

import SwiftUI

struct ConfirmSignUpView: View {
    var authManager: AuthManager
    let email: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var confirmationCode = ""
    @State private var isConfirmed = false
    @State private var resendCooldown = 0
    
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
                                .fill(AppTheme.secondaryTeal.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "envelope.badge.fill")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(AppTheme.secondaryTeal)
                        }
                        
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Text("Verify Your Email")
                                .font(AppTheme.Typography.displayMedium)
                                .foregroundColor(AppTheme.primaryDeepIndigo)
                            
                            Text("We sent a verification code to")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(email)
                                .font(AppTheme.Typography.titleMedium)
                                .foregroundColor(AppTheme.primaryDeepIndigo)
                        }
                    }
                    
                    if isConfirmed {
                        // Success state
                        VStack(spacing: AppTheme.Spacing.xl) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.green)
                            }
                            
                            Text("Email Verified!")
                                .font(AppTheme.Typography.headlineMedium)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("You can now sign in with your account.")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Button {
                                // Pop back to login
                                dismiss()
                            } label: {
                                Text("Go to Sign In")
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
                        }
                        .padding(AppTheme.Spacing.xxl)
                        .background(AppTheme.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
                        .shadow(color: AppTheme.shadowColor, radius: 16, x: 0, y: 8)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    } else {
                        // Code input
                        VStack(spacing: AppTheme.Spacing.lg) {
                            AuthFormField(
                                label: "Verification Code",
                                icon: "number",
                                placeholder: "Enter 6-digit code",
                                text: $confirmationCode,
                                keyboardType: .numberPad
                            )
                            
                            if let error = authManager.errorMessage {
                                AuthErrorMessage(message: error)
                            }
                            
                            AuthPrimaryButton(
                                title: "Verify",
                                isLoading: authManager.isLoading,
                                isDisabled: confirmationCode.count < 6
                            ) {
                                Task {
                                    let success = await authManager.confirmSignUp(
                                        email: email,
                                        code: confirmationCode
                                    )
                                    if success {
                                        isConfirmed = true
                                    }
                                }
                            }
                            
                            // Resend code
                            Button {
                                resendCooldown = 60
                                Task {
                                    await authManager.resendConfirmationCode(for: email)
                                    startCooldownTimer()
                                }
                            } label: {
                                if resendCooldown > 0 {
                                    Text("Resend code in \(resendCooldown)s")
                                        .font(AppTheme.Typography.bodySmall)
                                        .foregroundColor(AppTheme.textTertiary)
                                } else {
                                    Text("Didn't receive the code? Resend")
                                        .font(AppTheme.Typography.bodySmall)
                                        .foregroundColor(AppTheme.primaryDeepIndigo)
                                }
                            }
                            .disabled(resendCooldown > 0)
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
    
    private func startCooldownTimer() {
        Task {
            while resendCooldown > 0 {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    resendCooldown -= 1
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConfirmSignUpView(authManager: AuthManager(), email: "test@example.com")
    }
}
