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
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.bgSecondary,
                        AppTheme.bgPrimary,
                        AppTheme.bgTertiary.opacity(0.28)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    RadialGradient(
                        colors: [
                            AppTheme.accentGold.opacity(0.12),
                            Color.clear
                        ],
                        center: .topTrailing,
                        startRadius: 10,
                        endRadius: 260
                    )
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxxl) {
                        Spacer(minLength: 60)
                        
                        // Logo & Title
                        VStack(spacing: AppTheme.Spacing.lg) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentGold.opacity(0.12))
                                    .frame(width: 124, height: 124)

                                Circle()
                                    .stroke(AppTheme.borderColor.opacity(0.8), lineWidth: 1)
                                    .frame(width: 124, height: 124)

                                Image("beaver-main")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            }
                            
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Text("AI Planner")
                                    .font(AppTheme.Typography.displayLarge)
                                    .foregroundColor(AppTheme.primaryDeepIndigo)
                                
                                Text("Organize your schedule with intelligence")
                                    .font(AppTheme.Typography.bodyMedium)
                                    .foregroundColor(AppTheme.textSecondary)

                                Text("A calmer daily planner with a clever beaver by your side.")
                                    .font(AppTheme.Typography.bodySmall)
                                    .foregroundColor(AppTheme.textTertiary)
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
                        .background(AppTheme.bgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                                .stroke(AppTheme.borderColor.opacity(0.85), lineWidth: 1)
                        )
                        .shadow(color: AppTheme.Shadows.lg.color, radius: AppTheme.Shadows.lg.radius, x: AppTheme.Shadows.lg.x, y: AppTheme.Shadows.lg.y)
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
