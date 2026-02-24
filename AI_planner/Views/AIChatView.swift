//
//  AIChatView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct AIChatView: View {
    @ObservedObject var viewModel: TodoViewModel
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    @State private var showMenu = false
    
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
                                .fill(chatViewModel.isTyping ? AppTheme.secondaryTeal : Color.green)
                                .frame(width: 8, height: 8)
                            
                            Text(chatViewModel.isTyping ? "Thinking..." : "Online")
                                .font(AppTheme.Typography.labelSmall)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            chatViewModel.clearHistory()
                        } label: {
                            Label("New Chat", systemImage: "plus.bubble")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            chatViewModel.clearHistory()
                        } label: {
                            Label("Clear Chat", systemImage: "trash")
                        }
                    } label: {
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
                            ForEach(chatViewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            // Invisible anchor at the very bottom
                            Color.clear
                                .frame(height: 1)
                                .id("bottomAnchor")
                        }
                        .padding(.top, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.lg)
                    }
                    .onAppear {
                        scrollProxy.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                    .onChange(of: chatViewModel.messages.count) {
                        scrollToBottom(scrollProxy)
                    }
                    .onChange(of: chatViewModel.messages.last?.content) {
                        scrollToBottom(scrollProxy)
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
                            .onSubmit { sendMessage() }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(
                                    canSend ? AppTheme.secondaryTeal : AppTheme.textTertiary
                                )
                        }
                        .disabled(!canSend)
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
        .onAppear {
            chatViewModel.configure(with: viewModel)
        }
    }
    
    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !chatViewModel.isTyping
    }
    
    private func sendMessage() {
        guard canSend else { return }
        let text = inputText
        inputText = ""
        chatViewModel.sendMessage(text)
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo("bottomAnchor", anchor: .bottom)
        }
    }
}

#Preview {
    AIChatView(viewModel: .preview)
}
