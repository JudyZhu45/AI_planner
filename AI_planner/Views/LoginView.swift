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
                                    .foregroundColor(.white)
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
                                    
                                    SecureField("Enter your password", text: $password)
                                        .textContentType(.password)
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
                            
                            // Sign In button
                            Button {
                                Task {
                                    await authManager.signIn(email: email, password: password)
                                    if authManager.needsConfirmation {
                                        await MainActor.run {
                                            authManager.needsConfirmation = false
                                            showConfirmation = true
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("Sign In")
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
                            .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
                            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)
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
