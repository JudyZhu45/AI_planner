//
//  AuthPrimaryButton.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import SwiftUI

struct AuthPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if isLoading {
                    Image("beaver-loading")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                Text(title)
                    .font(AppTheme.Typography.titleLarge)
            }
            .foregroundColor(AppTheme.textInverse)
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.lg)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.primaryDeepIndigo,
                        AppTheme.accentGold
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: AppTheme.primaryDeepIndigo.opacity(0.22), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !isDisabled && !isLoading else { return }
                    withAnimation(.easeOut(duration: 0.12)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        isPressed = false
                    }
                }
        )
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthPrimaryButton(title: "Sign In", action: {})
        AuthPrimaryButton(title: "Loading...", isLoading: true, action: {})
        AuthPrimaryButton(title: "Disabled", isDisabled: true, action: {})
    }
    .padding()
}
