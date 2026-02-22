//
//  AuthManager.swift
//  AI_planner
//
//  Created by Judy459 on 2/22/26.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@Observable
class AuthManager {
    var isSignedIn = false
    var isLoading = true
    var errorMessage: String?
    var userEmail: String?
    var needsConfirmation = false
    
    init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - Check Current Auth Status
    func checkAuthStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            await MainActor.run {
                self.isSignedIn = session.isSignedIn
                self.isLoading = false
            }
            if session.isSignedIn {
                await fetchUserEmail()
            }
        } catch {
            await MainActor.run {
                self.isSignedIn = false
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async {
        await MainActor.run {
            self.errorMessage = nil
            self.isLoading = true
        }
        do {
            let result = try await Amplify.Auth.signIn(username: email, password: password)
            if result.isSignedIn {
                await fetchUserEmail()
                await MainActor.run {
                    self.isSignedIn = true
                    self.isLoading = false
                }
            } else {
                // Handle next steps
                switch result.nextStep {
                case .confirmSignInWithNewPassword:
                    // User was created in Console and needs to set a new password
                    let confirmResult = try await Amplify.Auth.confirmSignIn(
                        challengeResponse: password
                    )
                    if confirmResult.isSignedIn {
                        await fetchUserEmail()
                        await MainActor.run {
                            self.isSignedIn = true
                            self.isLoading = false
                        }
                    } else {
                        await MainActor.run {
                            self.isLoading = false
                            self.errorMessage = "Could not complete sign in."
                        }
                    }
                case .confirmSignUp:
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Please verify your email first. Check your inbox for a verification code, or contact support."
                    }
                default:
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Sign in requires additional steps."
                    }
                }
            }
        } catch let error as AuthError {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.errorDescription
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String) async -> Bool {
        await MainActor.run {
            self.errorMessage = nil
            self.isLoading = true
        }
        do {
            let options = AuthSignUpRequest.Options(
                userAttributes: [AuthUserAttribute(.email, value: email)]
            )
            let result = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )
            await MainActor.run {
                self.isLoading = false
            }
            switch result.nextStep {
            case .confirmUser:
                // Auto-confirm: skip email verification
                return true
            case .done:
                return true
            @unknown default:
                return true
            }
        } catch let error as AuthError {
            await MainActor.run {
                self.isLoading = false
            }
            let errorDesc = error.errorDescription.lowercased()
            if errorDesc.contains("username exists") || errorDesc.contains("already exists") {
                await MainActor.run {
                    self.errorMessage = "An account with this email already exists. Please sign in."
                }
                return false
            }
            await MainActor.run {
                self.errorMessage = error.errorDescription
            }
            return false
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Confirm Sign Up
    func confirmSignUp(email: String, code: String) async -> Bool {
        await MainActor.run {
            self.errorMessage = nil
            self.isLoading = true
        }
        do {
            let result = try await Amplify.Auth.confirmSignUp(
                for: email,
                confirmationCode: code
            )
            await MainActor.run {
                self.isLoading = false
            }
            return result.isSignUpComplete
        } catch let error as AuthError {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.errorDescription
            }
            return false
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Resend Confirmation Code
    func resendConfirmationCode(for email: String) async {
        await MainActor.run {
            self.errorMessage = nil
        }
        do {
            _ = try await Amplify.Auth.resendSignUpCode(for: email)
        } catch let error as AuthError {
            await MainActor.run {
                self.errorMessage = error.errorDescription
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(for email: String) async -> Bool {
        await MainActor.run {
            self.errorMessage = nil
            self.isLoading = true
        }
        do {
            let result = try await Amplify.Auth.resetPassword(for: email)
            await MainActor.run {
                self.isLoading = false
            }
            switch result.nextStep {
            case .confirmResetPasswordWithCode:
                return true
            case .done:
                return false
            @unknown default:
                return false
            }
        } catch let error as AuthError {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.errorDescription
            }
            return false
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Confirm Reset Password
    func confirmResetPassword(for email: String, newPassword: String, code: String) async -> Bool {
        await MainActor.run {
            self.errorMessage = nil
            self.isLoading = true
        }
        do {
            try await Amplify.Auth.confirmResetPassword(
                for: email,
                with: newPassword,
                confirmationCode: code
            )
            await MainActor.run {
                self.isLoading = false
            }
            return true
        } catch let error as AuthError {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.errorDescription
            }
            return false
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Sign Out
    func signOut() async {
        await MainActor.run {
            self.isLoading = true
        }
        _ = await Amplify.Auth.signOut()
        await MainActor.run {
            self.isSignedIn = false
            self.userEmail = nil
            self.isLoading = false
        }
    }
    
    // MARK: - Fetch User Email
    private func fetchUserEmail() async {
        do {
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            if let email = attributes.first(where: { $0.key == .email })?.value {
                await MainActor.run {
                    self.userEmail = email
                }
            }
        } catch {
            // Silently fail - email display is not critical
        }
    }
}
