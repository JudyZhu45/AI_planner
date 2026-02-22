//
//  SignUpView.swift
//  AI_planner
//
//  Created by Judy459 on 2/22/26.
//

import SwiftUI

struct SignUpView: View {
    var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var signUpSuccess = false
    
    private var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && passwordsMatch
    }
    
    var body: some View {
        ZStack {
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xxxl) {
                    Spacer(minLength: 20)
                    
                    // Header
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text(signUpSuccess ? "Account Created!" : "Create Account")
                            .font(AppTheme.Typography.displayMedium)
                            .foregroundColor(AppTheme.primaryDeepIndigo)
                        
                        Text(signUpSuccess
                             ? "You can now sign in with your account."
                             : "Start organizing your life today")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Form Card
                    VStack(spacing: AppTheme.Spacing.lg) {
                        if signUpSuccess {
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
                                
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Go to Sign In")
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
                            }
                        } else {
                            // Registration form
                            // Email field
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
                            
                            // Password field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                Text("Password")
                                    .font(AppTheme.Typography.labelLarge)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack(spacing: AppTheme.Spacing.md) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textTertiary)
                                    
                                    SecureField("Min. 8 characters", text: $password)
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
                                
                                Text("Must include uppercase, lowercase, number & symbol")
                                    .font(AppTheme.Typography.labelSmall)
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                            
                            // Confirm Password field
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                Text("Confirm Password")
                                    .font(AppTheme.Typography.labelLarge)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack(spacing: AppTheme.Spacing.md) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textTertiary)
                                    
                                    SecureField("Re-enter your password", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .font(AppTheme.Typography.bodyLarge)
                                }
                                .padding(AppTheme.Spacing.lg)
                                .background(AppTheme.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(
                                            !confirmPassword.isEmpty && !passwordsMatch
                                                ? AppTheme.accentCoral
                                                : AppTheme.borderColor,
                                            lineWidth: 1
                                        )
                                )
                                
                                if !confirmPassword.isEmpty && !passwordsMatch {
                                    Text("Passwords do not match")
                                        .font(AppTheme.Typography.labelSmall)
                                        .foregroundColor(AppTheme.accentCoral)
                                }
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
                            
                            // Sign Up button
                            Button {
                                handleSignUp()
                            } label: {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("Create Account")
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
                            .disabled(!isFormValid || authManager.isLoading)
                            .opacity(!isFormValid ? 0.6 : 1)
                        }
                    }
                    .padding(AppTheme.Spacing.xxl)
                    .background(AppTheme.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
                    .shadow(color: AppTheme.shadowColor, radius: 16, x: 0, y: 8)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
    
    private func handleSignUp() {
        Task { @MainActor in
            let success = await authManager.signUp(email: email, password: password)
            if success {
                self.signUpSuccess = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(authManager: AuthManager())
    }
}
