//
//  MessageBubble.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

enum MessageSender: String, Codable {
    case user
    case ai
}

struct Message: Identifiable, Codable {
    let id: UUID
    var content: String
    let sender: MessageSender
    let timestamp: Date
    var isStreaming: Bool
    var isError: Bool
    
    init(
        content: String,
        sender: MessageSender,
        timestamp: Date,
        isStreaming: Bool = false,
        isError: Bool = false
    ) {
        self.id = UUID()
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.isError = isError
    }
}

struct MessageBubble: View {
    let message: Message
    
    var isUserMessage: Bool {
        message.sender == .user
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.md) {
            if isUserMessage {
                Spacer()
            }
            
            VStack(alignment: isUserMessage ? .trailing : .leading, spacing: AppTheme.Spacing.xs) {
                if message.content.isEmpty && message.isStreaming {
                    // Streaming placeholder — dots
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(AppTheme.textTertiary)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.bgTertiary)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: AppTheme.Radius.xl,
                            style: .continuous
                        )
                    )
                } else {
                    Text(message.content)
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(
                            isUserMessage
                                ? AppTheme.textInverse
                                : message.isError ? AppTheme.accentCoral : AppTheme.textPrimary
                        )
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            isUserMessage
                                ? AppTheme.primaryDeepIndigo
                                : message.isError ? AppTheme.accentCoral.opacity(0.1) : AppTheme.bgTertiary
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: AppTheme.Radius.xl,
                                style: .continuous
                            )
                        )
                }
                
                Text(timeString)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            
            if !isUserMessage {
                Spacer()
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        MessageBubble(message: Message(
            content: "Hi! I can help you organize your schedule. What would you like to focus on today?",
            sender: .ai,
            timestamp: Date()
        ))
        
        MessageBubble(message: Message(
            content: "I want to balance my workout and study time better",
            sender: .user,
            timestamp: Date()
        ))
        
        MessageBubble(message: Message(
            content: "Great! I suggest dedicating 2 hours to study in the afternoon and 1 hour for exercise in the morning. This gives your mind time to recover after morning workouts.",
            sender: .ai,
            timestamp: Date()
        ))
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.bgPrimary)
}
