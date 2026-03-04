//
//  SwipeHintOverlay.swift
//  AI_planner
//
//  Created by Judy459 on 3/4/26.
//

import SwiftUI

struct SwipeHintOverlay: View {
    @State private var showHint = false
    @State private var offsetX: CGFloat = 0
    
    private static let hasShownKey = "hasShownSwipeHint"
    
    var body: some View {
        Group {
            if showHint {
                HStack(spacing: 0) {
                    // Left hint (swipe right to complete)
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Complete")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppTheme.secondaryTeal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.secondaryTeal.opacity(0.12))
                    .clipShape(Capsule())
                    .offset(x: offsetX)
                    
                    Spacer()
                    
                    // Right hint (swipe left to delete)
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .bold))
                        Text("Delete")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.accentCoral)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.accentCoral.opacity(0.12))
                    .clipShape(Capsule())
                    .offset(x: -offsetX)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .transition(.opacity)
            }
        }
        .onAppear {
            guard !UserDefaults.standard.bool(forKey: Self.hasShownKey) else { return }
            
            withAnimation(.easeOut(duration: 0.4)) {
                showHint = true
            }
            
            // Animate the arrows moving outward
            withAnimation(
                .easeInOut(duration: 0.8)
                .repeatCount(3, autoreverses: true)
                .delay(0.4)
            ) {
                offsetX = 12
            }
            
            // Auto-dismiss after 3.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showHint = false
                }
                UserDefaults.standard.set(true, forKey: Self.hasShownKey)
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                showHint = false
            }
            UserDefaults.standard.set(true, forKey: Self.hasShownKey)
        }
    }
}

#Preview {
    VStack {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(height: 70)
                .shadow(radius: 2)
                .padding(.horizontal)
            
            SwipeHintOverlay()
        }
        Spacer()
    }
    .padding(.top, 100)
    .background(AppTheme.bgPrimary)
}
