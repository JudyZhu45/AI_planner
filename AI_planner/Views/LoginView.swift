//
//  LoginView.swift
//  AI_planner
//
//  Created by Judy459 on 2/22/26.
//

import SwiftUI

struct LoginView: View {
    var authManager: AuthManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.bgPrimary,
                        AppTheme.primaryDeepIndigo.opacity(0.05)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxxl) {
                        Spacer(minLength: 60)
                        
                        // Logo & Title
                        VStack(spacing: AppTheme.Spacing.lg) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppTheme.primaryDeepIndigo,
                                                AppTheme.secondaryTeal
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "brain.head.profile.fill")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(AppTheme.textInverse)
                            }
                            
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Text("AI Planner")
                                    .font(AppTheme.Typography.displayLarge)
                                    .foregroundColor(AppTheme.primaryDeepIndigo)
                                
                                Text("Organize your schedule with intelligence")
                                    .font(AppTheme.Typography.bodyMedium)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        
                        // Form
                        VStack(spacing: AppTheme.Spacing.lg) {
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
                                placeholder: "Enter your password",
                                text: $password,
                                isSecure: true,
                                textContentType: .password
                            )
                            
                            // Forgot password
                            HStack {
                                Spacer()
                                Button {
                                    showForgotPassword = true
                                } label: {
                                    Text("Forgot Password?")
                                        .font(AppTheme.Typography.bodySmall)
                                        .foregroundColor(AppTheme.primaryDeepIndigo)
                                }
                            }
                            
                            if let error = authManager.errorMessage {
                                AuthErrorMessage(message: error)
                            }
                            
                            AuthPrimaryButton(
                                title: "Sign In",
                                isLoading: authManager.isLoading,
                                isDisabled: email.isEmpty || password.isEmpty
                            ) {
                                Task {
                                    await authManager.signIn(email: email, password: password)
                                    if authManager.needsConfirmation {
                                        await MainActor.run {
                                            authManager.needsConfirmation = false
                                            showConfirmation = true
                                        }
                                    }
                                }
                            }
                        }
                        .padding(AppTheme.Spacing.xxl)
                        .background(AppTheme.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
                        .shadow(color: AppTheme.shadowColor, radius: 16, x: 0, y: 8)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        // Sign Up link
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Text("Don't have an account?")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Button {
                                showSignUp = true
                            } label: {
                                Text("Sign Up")
                                    .font(AppTheme.Typography.titleMedium)
                                    .foregroundColor(AppTheme.primaryDeepIndigo)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(authManager: authManager)
            }
            .navigationDestination(isPresented: $showForgotPassword) {
                ForgotPasswordView(authManager: authManager)
            }
            .fullScreenCover(isPresented: $showConfirmation) {
                NavigationStack {
                    ConfirmSignUpView(authManager: authManager, email: email)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back") {
                                    showConfirmation = false
                                }
                                .foregroundColor(AppTheme.primaryDeepIndigo)
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    LoginView(authManager: AuthManager())
}
