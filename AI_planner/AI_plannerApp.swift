//
//  AI_plannerApp.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@main
struct AI_plannerApp: App {
    @State private var authManager = AuthManager()
    
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isLoading {
                // Splash / loading screen
                ZStack {
                    AppTheme.bgPrimary
                        .ignoresSafeArea()
                    
                    VStack(spacing: AppTheme.Spacing.lg) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(AppTheme.primaryDeepIndigo)
                        
                        Text("AI Planner")
                            .font(AppTheme.Typography.headlineLarge)
                            .foregroundColor(AppTheme.primaryDeepIndigo)
                    }
                }
            } else if authManager.isSignedIn {
                ContentView(authManager: authManager)
            } else {
                LoginView(authManager: authManager)
            }
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
        } catch {
            print("Failed to configure Amplify: \(error)")
        }
    }
}
