//
//  ToastView.swift
//  AI_planner
//
//  Created by Judy459 on 3/4/26.
//

import SwiftUI

struct ToastView: View {
    let toast: ToastMessage
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            if let assetIcon = toast.type.assetIcon {
                Image(assetIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: toast.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(toast.type.color)
            }
            
            Text(toast.message)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(2)
            
            Spacer(minLength: 0)
            
            if let undoAction = toast.undoAction {
                Button {
                    undoAction()
                    onDismiss()
                } label: {
                    Text("Undo")
                        .font(AppTheme.Typography.titleSmall)
                        .foregroundColor(toast.type.color)
                }
            }
            
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(AppTheme.bgSecondary)
                .shadow(color: AppTheme.shadowColor.opacity(0.3), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .stroke(toast.type.color.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

// MARK: - Toast Overlay (placed in root view)

struct ToastOverlay: View {
    var toastManager = ToastManager.shared
    
    var body: some View {
        VStack {
            if let toast = toastManager.currentToast {
                ToastView(toast: toast, onDismiss: {
                    toastManager.dismiss()
                })
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(999)
            }
            
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.currentToast?.id)
    }
}

#Preview {
    ZStack {
        AppTheme.bgPrimary.ignoresSafeArea()
        
        VStack(spacing: AppTheme.Spacing.lg) {
            ToastView(
                toast: ToastMessage(message: "Task completed!", type: .success),
                onDismiss: {}
            )
            
            ToastView(
                toast: ToastMessage(message: "Task deleted", type: .error, undoAction: {}),
                onDismiss: {}
            )
            
            ToastView(
                toast: ToastMessage(message: "End time should be after start time", type: .warning),
                onDismiss: {}
            )
            
            ToastView(
                toast: ToastMessage(message: "Swipe left to complete tasks", type: .info),
                onDismiss: {}
            )
        }
        .padding(.top, AppTheme.Spacing.xl)
    }
}
