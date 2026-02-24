//
//  ChatViewModel.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping = false
    @Published var errorMessage: String?
    
    let chatService = ChatService()
    
    private let chatHistoryKey = "SavedChatHistory"
    private var streamingObserver: AnyCancellable?
    
    init() {
        loadChatHistory()
        if messages.isEmpty {
            messages = [
                Message(
                    content: "你好！我是你的 AI 日程助手。我可以帮你创建任务、规划日程、管理待办事项。\n\n试试说：\"帮我明天下午3点安排一个会议\" 或 \"帮我规划明天的安排\"",
                    sender: .ai,
                    timestamp: Date()
                )
            ]
        }
        
        // Observe streaming text changes
        streamingObserver = chatService.$streamingText
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                self?.updateStreamingMessage(with: newText)
            }
    }
    
    func configure(with todoViewModel: TodoViewModel) {
        chatService.todoViewModel = todoViewModel
    }
    
    // MARK: - Send Message
    
    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Add user message
        let userMessage = Message(content: trimmed, sender: .user, timestamp: Date())
        messages.append(userMessage)
        
        // Add streaming placeholder
        let placeholder = Message(content: "", sender: .ai, timestamp: Date(), isStreaming: true)
        messages.append(placeholder)
        
        isTyping = true
        errorMessage = nil
        
        Task {
            await chatService.sendMessage(trimmed)
            
            // Update final message
            if let lastIndex = messages.indices.last, messages[lastIndex].sender == .ai {
                if let error = chatService.lastError {
                    messages[lastIndex] = Message(
                        content: error,
                        sender: .ai,
                        timestamp: Date(),
                        isError: true
                    )
                    errorMessage = error
                } else {
                    var finalContent = chatService.streamingText
                    
                    // Append action confirmations
                    if !chatService.executedActions.isEmpty {
                        let confirmations = chatService.executedActions.map { "✅ \($0)" }.joined(separator: "\n")
                        finalContent += "\n\n\(confirmations)"
                    }
                    
                    messages[lastIndex] = Message(
                        content: finalContent,
                        sender: .ai,
                        timestamp: Date()
                    )
                }
            }
            
            isTyping = false
            saveChatHistory()
        }
    }
    
    // MARK: - Streaming Update
    
    private func updateStreamingMessage(with text: String) {
        guard isTyping,
              let lastIndex = messages.indices.last,
              messages[lastIndex].sender == .ai,
              messages[lastIndex].isStreaming else { return }
        
        messages[lastIndex] = Message(
            content: text,
            sender: .ai,
            timestamp: Date(),
            isStreaming: true
        )
    }
    
    // MARK: - Clear Chat
    
    func clearHistory() {
        chatService.resetConversation()
        UserDefaults.standard.removeObject(forKey: chatHistoryKey)
        messages = [
            Message(
                content: "对话已清除！有什么可以帮你的？",
                sender: .ai,
                timestamp: Date()
            )
        ]
    }
    
    // MARK: - Persistence
    
    private func saveChatHistory() {
        // Only save last 50 messages, exclude streaming state
        let toSave = messages.suffix(50).map { msg -> Message in
            Message(
                content: msg.content,
                sender: msg.sender,
                timestamp: msg.timestamp,
                isStreaming: false,
                isError: msg.isError
            )
        }
        if let encoded = try? JSONEncoder().encode(Array(toSave)) {
            UserDefaults.standard.set(encoded, forKey: chatHistoryKey)
        }
    }
    
    private func loadChatHistory() {
        if let data = UserDefaults.standard.data(forKey: chatHistoryKey),
           let decoded = try? JSONDecoder().decode([Message].self, from: data) {
            messages = decoded
        }
    }
}
