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
                        } else {
                            // Registration form
                            AuthFormField(
                                label: "Email",
                                icon: "envelope.fill",
                                placeholder: "your@email.com",
                                text: $email,
                                textContentType: .emailAddress,
                                keyboardType: .emailAddress
                            )
                            
                            AuthFormField(
                                label: "Password",
                                icon: "lock.fill",
                                placeholder: "Min. 8 characters",
                                text: $password,
                                isSecure: true,
                                textContentType: .newPassword,
                                hint: "Must include uppercase, lowercase, number & symbol"
                            )
                            
                            AuthFormField(
                                label: "Confirm Password",
                                icon: "lock.fill",
                                placeholder: "Re-enter your password",
                                text: $confirmPassword,
                                isSecure: true,
                                textContentType: .newPassword,
                                showError: !confirmPassword.isEmpty && !passwordsMatch,
                                errorMessage: "Passwords do not match"
                            )
                            
                            if let error = authManager.errorMessage {
                                AuthErrorMessage(message: error)
                            }
                            
                            AuthPrimaryButton(
                                title: "Create Account",
                                isLoading: authManager.isLoading,
                                isDisabled: !isFormValid
                            ) {
                                handleSignUp()
                            }
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
