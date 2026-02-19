//
//  AIChatView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct AIChatView: View {
    @State private var messages: [Message] = []
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    let initialMessages = [
        Message(
            content: "👋 Hi! I'm your AI planning assistant. I can help you organize your schedule, optimize your time, and keep you on track with your goals.",
            sender: .ai,
            timestamp: Date(timeIntervalSinceNow: -120)
        ),
        Message(
            content: "What would you like to focus on today?",
            sender: .ai,
            timestamp: Date(timeIntervalSinceNow: -60)
        ),
    ]
    
    var body: some View {
        ZStack {
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Assistant")
                            .font(AppTheme.Typography.headlineMedium)
                            .foregroundColor(AppTheme.primaryDeepIndigo)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            
                            Text("Always available")
                                .font(AppTheme.Typography.labelSmall)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.bgSecondary)
                .shadow(color: AppTheme.shadowColor, radius: 4, x: 0, y: 2)
                
                // Messages
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: AppTheme.Spacing.md) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            Spacer(minLength: AppTheme.Spacing.xl)
                        }
                        .padding(.top, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.lg)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            scrollProxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        messages = initialMessages
                        scrollProxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
                
                // Input Area
                VStack(spacing: AppTheme.Spacing.md) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        TextField("Ask me anything...", text: $inputText)
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.textPrimary)
                            .focused($isInputFocused)
                            .textFieldStyle(.plain)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? AppTheme.textTertiary : AppTheme.secondaryTeal)
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.bgSecondary)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                isInputFocused ? AppTheme.secondaryTeal : AppTheme.borderColor,
                                lineWidth: 1.5
                            )
                    )
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.lg)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppTheme.bgPrimary.opacity(0),
                            AppTheme.bgPrimary
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
    
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespaces)
        guard !userMessage.isEmpty else { return }
        
        messages.append(Message(content: userMessage, sender: .user, timestamp: Date()))
        inputText = ""
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let aiResponses = [
                "That's a great observation! Let me analyze your schedule and suggest some optimizations.",
                "I can help with that. Based on your calendar, I recommend blocking off focused time in the morning.",
                "Excellent point. Let me update your priorities to align with that goal.",
                "I see you're balancing multiple tasks. I'd suggest tackling the high-priority items first.",
                "Great question! Here's what I think would work best for your schedule...",
            ]
            
            let randomResponse = aiResponses.randomElement() ?? "I'm here to help!"
            messages.append(Message(content: randomResponse, sender: .ai, timestamp: Date()))
        }
    }
}

#Preview {
    AIChatView()
}
