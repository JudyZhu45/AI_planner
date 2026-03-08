//
//  AuthManager.swift
//  AI_planner
//
//  Created by Judy459 on 2/22/26.
//

import SwiftUI

@Observable
class AuthManager {
    var isSignedIn = true
    var isLoading = false
    var errorMessage: String?
    var userEmail: String? = "Local User"
    var needsConfirmation = false
    
    init() {
        isSignedIn = true
        isLoading = false
    }
    
    // MARK: - Local Auth Status
    func checkAuthStatus() async {
        await MainActor.run {
            self.isSignedIn = true
            self.isLoading = false
            if self.userEmail == nil {
                self.userEmail = "Local User"
            }
        }
    }
    
    // MARK: - Sign In (local bypass)
    func signIn(email: String, password: String) async {
        await MainActor.run {
            self.errorMessage = nil
            self.isLoading = true
        }
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        await MainActor.run {
            self.userEmail = trimmedEmail.isEmpty ? "Local User" : trimmedEmail
            self.isSignedIn = true
            self.isLoading = false
        }
    }
    
    // MARK: - Sign Up (disabled)
    func signUp(email: String, password: String) async -> Bool {
        await MainActor.run {
            self.isLoading = false
            self.errorMessage = "Sign up is disabled in the local no-auth build."
        }
        return false
    }
    
    // MARK: - Confirm Sign Up (disabled)
    func confirmSignUp(email: String, code: String) async -> Bool {
        await MainActor.run {
            self.isLoading = false
            self.errorMessage = "Email confirmation is disabled in the local no-auth build."
        }
        return false
    }
    
    // MARK: - Resend Confirmation Code (disabled)
    func resendConfirmationCode(for email: String) async {
        await MainActor.run {
            self.errorMessage = "Confirmation emails are disabled in the local no-auth build."
        }
    }
    
    // MARK: - Reset Password (disabled)
    func resetPassword(for email: String) async -> Bool {
        await MainActor.run {
            self.isLoading = false
            self.errorMessage = "Password reset is disabled in the local no-auth build."
        }
        return false
    }
    
    // MARK: - Confirm Reset Password (disabled)
    func confirmResetPassword(for email: String, newPassword: String, code: String) async -> Bool {
        await MainActor.run {
            self.isLoading = false
            self.errorMessage = "Password reset confirmation is disabled in the local no-auth build."
        }
        return false
    }
    
    // MARK: - Sign Out
    func signOut() async {
        await MainActor.run {
            self.isSignedIn = true
            self.userEmail = "Local User"
            self.errorMessage = "Sign out is disabled in the local no-auth build."
            self.isLoading = false
        }
    }
}
