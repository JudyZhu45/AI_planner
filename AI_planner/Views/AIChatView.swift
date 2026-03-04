//
//  AIChatView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct QuickPrompt: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let prompt: String
}

private let quickPrompts: [QuickPrompt] = [
    QuickPrompt(icon: "sun.max", label: "规划今天", prompt: "帮我规划今天的安排"),
    QuickPrompt(icon: "calendar.badge.plus", label: "规划明天", prompt: "帮我规划明天的安排"),
    QuickPrompt(icon: "calendar", label: "规划本周", prompt: "帮我规划这周剩余的安排"),
    QuickPrompt(icon: "book", label: "学习计划", prompt: "帮我制定一个学习计划"),
    QuickPrompt(icon: "figure.run", label: "健身计划", prompt: "帮我制定一个健身计划"),
    QuickPrompt(icon: "list.bullet", label: "查看任务", prompt: "帮我总结一下目前所有的任务"),
]

struct AIChatView: View {
    @ObservedObject var viewModel: TodoViewModel
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var speechService = SpeechRecognitionService()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    @State private var showMenu = false
    @State private var micPulse = false
    
    var body: some View {
        ZStack {
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Messages
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(chatViewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    onCopy: {
                                        chatViewModel.copyMessageContent(message)
                                    },
                                    onDelete: {
                                        withAnimation {
                                            chatViewModel.deleteMessage(message)
                                        }
                                    }
                                )
                                .id(message.id)
                            }
                            
                            // Action results cards
                            if !chatViewModel.lastActionResults.isEmpty {
                                actionResultsView
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                            
                            // Confirm button — when AI proposes a plan
                            if chatViewModel.showConfirmButton {
                                confirmButtonView
                                    .transition(.opacity.combined(with: .scale))
                            }
                            
                            // Quick prompts — show when only welcome message
                            if showQuickPrompts {
                                quickPromptsView
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                            
                            // Invisible anchor at the very bottom
                            Color.clear
                                .frame(height: 1)
                                .id("bottomAnchor")
                        }
                        .padding(.top, AppTheme.Spacing.md)
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
                inputAreaView
            }
        }
        .onAppear {
            chatViewModel.configure(with: viewModel)
        }
        .onChange(of: speechService.recognizedText) { _, newValue in
            if speechService.isRecording && !newValue.isEmpty {
                inputText = newValue
            }
        }
        .alert("语音识别", isPresented: Binding(
            get: { speechService.errorMessage != nil },
            set: { if !$0 { speechService.errorMessage = nil } }
        )) {
            Button("好的", role: .cancel) {
                speechService.errorMessage = nil
            }
        } message: {
            Text(speechService.errorMessage ?? "")
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // AI Avatar in header
            Image("beaver-main")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Assistant")
                    .font(AppTheme.Typography.headlineSmall)
                    .foregroundColor(AppTheme.primaryDeepIndigo)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(chatViewModel.isTyping ? AppTheme.secondaryTeal : Color.green)
                        .frame(width: 6, height: 6)
                    
                    Text(chatViewModel.isTyping ? "Thinking..." : "Online")
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            Spacer()
            
            // Message count badge
            if chatViewModel.messages.count > 1 {
                Text("\(chatViewModel.messages.count - 1)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.bgTertiary)
                    .clipShape(Capsule())
            }
            
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
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.bgSecondary)
        .shadow(color: AppTheme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Input Area
    
    private var inputAreaView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: AppTheme.Spacing.sm) {
                ZStack(alignment: .topLeading) {
                    // Placeholder
                    if inputText.isEmpty {
                        Text(speechService.isRecording ? "正在听你说..." : "Ask me anything...")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(speechService.isRecording ? AppTheme.accentCoral : AppTheme.textTertiary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $inputText)
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.textPrimary)
                        .focused($isInputFocused)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 36, maxHeight: 120)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Microphone button
                Button {
                    Task {
                        await speechService.toggleRecording()
                    }
                } label: {
                    Image(systemName: speechService.isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 20))
                        .foregroundColor(
                            speechService.isRecording ? AppTheme.accentCoral : AppTheme.textSecondary
                        )
                        .frame(width: 32, height: 32)
                        .scaleEffect(micPulse ? 1.15 : 1.0)
                }
                .padding(.bottom, 2)
                .onChange(of: speechService.isRecording) { _, recording in
                    withAnimation(recording
                        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .default
                    ) {
                        micPulse = recording
                    }
                }
                
                // Send button
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(
                            canSend ? AppTheme.secondaryTeal : AppTheme.textTertiary
                        )
                }
                .disabled(!canSend)
                .padding(.bottom, 2)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        speechService.isRecording ? AppTheme.accentCoral :
                        isInputFocused ? AppTheme.secondaryTeal : AppTheme.borderColor,
                        lineWidth: speechService.isRecording ? 2.0 : 1
                    )
            )
            .shadow(color: AppTheme.shadowColor, radius: 4, x: 0, y: -2)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.md)
        }
        .background(
            AppTheme.bgPrimary
                .shadow(color: AppTheme.shadowColor, radius: 8, x: 0, y: -4)
        )
    }
    
    // MARK: - Helpers
    
    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !chatViewModel.isTyping
    }
    
    private func sendMessage() {
        guard canSend else { return }
        if speechService.isRecording {
            speechService.stopRecording()
        }
        let text = inputText
        inputText = ""
        chatViewModel.sendMessage(text)
    }
    
    // MARK: - Action Results
    
    private var actionResultsView: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            ForEach(chatViewModel.lastActionResults) { result in
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: result.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(actionColor(for: result.actionType))
                        .frame(width: 24, height: 24)
                        .background(actionColor(for: result.actionType).opacity(0.1))
                        .clipShape(Circle())
                    
                    Text(result.label)
                        .font(AppTheme.Typography.labelMedium)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if result.undoData != nil {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                chatViewModel.undoAction(result)
                            }
                        } label: {
                            Text("撤销")
                                .font(AppTheme.Typography.labelSmall)
                                .foregroundColor(AppTheme.accentCoral)
                                .padding(.horizontal, AppTheme.Spacing.sm)
                                .padding(.vertical, 3)
                                .background(AppTheme.accentCoral.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .stroke(actionColor(for: result.actionType).opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    private func actionColor(for type: ActionResult.ActionResultType) -> Color {
        switch type {
        case .created: return AppTheme.secondaryTeal
        case .updated: return Color.orange
        case .deleted: return AppTheme.accentCoral
        case .completed: return Color.green
        case .warning: return Color.orange
        }
    }
    
    // MARK: - Confirm Button
    
    private var confirmButtonView: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Button {
                withAnimation {
                    chatViewModel.showConfirmButton = false
                }
            } label: {
                Text("取消")
                    .font(AppTheme.Typography.labelMedium)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.bgTertiary)
                    .clipShape(Capsule())
            }
            
            Button {
                withAnimation {
                    chatViewModel.confirmProposal()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text("确认添加")
                        .font(AppTheme.Typography.labelMedium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    LinearGradient(
                        colors: [AppTheme.secondaryTeal, AppTheme.secondaryTeal.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: AppTheme.secondaryTeal.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // MARK: - Quick Prompts
    
    private var showQuickPrompts: Bool {
        chatViewModel.messages.count <= 1 && !chatViewModel.isTyping
    }
    
    private var quickPromptsView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Quick Start")
                .font(AppTheme.Typography.labelLarge)
                .foregroundColor(AppTheme.textTertiary)
                .padding(.horizontal, AppTheme.Spacing.xs)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                ForEach(quickPrompts) { prompt in
                    Button {
                        inputText = prompt.prompt
                        sendMessage()
                    } label: {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: prompt.icon)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.secondaryTeal)
                                .frame(width: 24, height: 24)
                                .background(AppTheme.secondaryTeal.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text(prompt.label)
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(AppTheme.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .stroke(AppTheme.borderColor, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
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
