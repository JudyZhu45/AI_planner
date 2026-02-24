//
//  ChatService.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - AI Action Models

enum AIAction {
    case createTask(AITaskData)
    case createMultipleTasks([AITaskData])
    case updateTask(id: String, fields: AITaskData)
    case deleteTask(id: String)
    case completeTask(id: String)
}

struct AITaskData {
    var title: String
    var description: String?
    var dueDate: String?      // "2026-02-25" ISO format
    var startTime: String?    // "15:00" 24hr format
    var endTime: String?      // "16:00"
    var priority: String?     // "low", "medium", "high"
    var eventType: String?    // "gym", "class", "study", "meeting", "dinner", "other"
}

// MARK: - Chat Service

@MainActor
class ChatService: ObservableObject {
    @Published var isLoading = false
    @Published var streamingText = ""
    @Published var lastError: String?
    @Published var executedActions: [String] = []
    
    private let api = KimiAPIService.shared
    private var conversationHistory: [KimiMessage] = []
    
    weak var todoViewModel: TodoViewModel?
    
    init() {}
    
    // MARK: - System Prompt
    
    private func buildSystemPrompt() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let currentTime = timeFormatter.string(from: Date())
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        let weekday = weekdayFormatter.string(from: Date())
        
        let tasksContext = buildTasksContext()
        
        return """
        You are an intelligent planning assistant integrated into a task management app. \
        You can both chat naturally AND manage the user's tasks directly.

        TODAY: \(today) (\(weekday))
        CURRENT TIME: \(currentTime)

        ## Your Capabilities
        1. Chat: Answer questions, give advice, help plan
        2. Create tasks: When the user asks you to schedule something
        3. Update tasks: Modify existing task details
        4. Delete tasks: Remove tasks the user no longer needs
        5. Complete tasks: Mark tasks as done
        6. Plan schedules: Create a full day/week plan with multiple tasks at once

        ## Current Tasks
        \(tasksContext)

        ## Action Format
        When you need to create, update, delete, or complete tasks, include an action block \
        in your response using this EXACT format:

        For creating a single task:
        [ACTION]
        {"action": "create_task", "task": {"title": "Meeting", "description": "Team standup", "due_date": "2026-02-25", "start_time": "15:00", "end_time": "16:00", "priority": "high", "event_type": "meeting"}}
        [/ACTION]

        For planning (creating multiple tasks at once):
        [ACTION]
        {"action": "create_multiple", "tasks": [
          {"title": "Gym", "due_date": "2026-02-25", "start_time": "08:00", "end_time": "09:00", "priority": "medium", "event_type": "gym"},
          {"title": "Study", "due_date": "2026-02-25", "start_time": "10:00", "end_time": "12:00", "priority": "high", "event_type": "study"}
        ]}
        [/ACTION]

        For updating an existing task (use the task ID from the list above):
        [ACTION]
        {"action": "update_task", "task_id": "UUID-HERE", "task": {"title": "New title", "start_time": "14:00"}}
        [/ACTION]

        For deleting a task:
        [ACTION]
        {"action": "delete_task", "task_id": "UUID-HERE"}
        [/ACTION]

        For completing a task:
        [ACTION]
        {"action": "complete_task", "task_id": "UUID-HERE"}
        [/ACTION]

        ## Rules
        - ALWAYS respond in the SAME LANGUAGE as the user's message
        - Include natural conversational text ALONGSIDE any action blocks
        - Check existing tasks to AVOID time conflicts before scheduling
        - Use 24-hour time format (HH:mm) for start_time and end_time
        - Use ISO date format (YYYY-MM-DD) for due_date
        - Valid event_type values: gym, class, study, meeting, dinner, other
        - Valid priority values: low, medium, high
        - For "tomorrow", calculate the correct date from TODAY (\(today))
        - For "next week", calculate dates starting from next Monday
        - When planning a day, consider reasonable gaps between tasks for rest/travel
        - If the user's request is ambiguous, ask for clarification instead of guessing
        - When creating timed events, ALWAYS include both start_time and end_time
        - The action block must contain valid JSON on a single logical block
        """
    }
    
    private func buildTasksContext() -> String {
        guard let vm = todoViewModel else { return "No tasks loaded." }
        if vm.todos.isEmpty { return "No tasks currently scheduled." }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        var lines: [String] = []
        for task in vm.todos.sorted(by: { $0.dueDate < $1.dueDate }) {
            var parts = [
                "ID: \(task.id.uuidString)",
                "Title: \(task.title)",
                "Date: \(dateFormatter.string(from: task.dueDate))",
                "Priority: \(task.priority.rawValue)",
                "Type: \(task.eventType.rawValue)",
                "Completed: \(task.isCompleted)"
            ]
            if let start = task.startTime {
                parts.append("Start: \(timeFormatter.string(from: start))")
            }
            if let end = task.endTime {
                parts.append("End: \(timeFormatter.string(from: end))")
            }
            if !task.description.isEmpty {
                parts.append("Desc: \(task.description)")
            }
            lines.append("- " + parts.joined(separator: " | "))
        }
        return lines.joined(separator: "\n")
    }
    
    // MARK: - Send Message (Streaming)
    
    func sendMessage(_ userMessage: String) async {
        isLoading = true
        streamingText = ""
        lastError = nil
        executedActions = []
        
        // Refresh system prompt with latest task context
        if conversationHistory.isEmpty {
            conversationHistory.append(KimiMessage(role: "system", content: buildSystemPrompt()))
        } else {
            conversationHistory[0] = KimiMessage(role: "system", content: buildSystemPrompt())
        }
        
        conversationHistory.append(KimiMessage(role: "user", content: userMessage))
        
        do {
            let stream = try await api.streamChat(messages: conversationHistory)
            var fullResponse = ""
            
            for try await chunk in stream {
                fullResponse += chunk
                streamingText = stripActionBlocks(from: fullResponse)
            }
            
            // Store full response in history
            conversationHistory.append(KimiMessage(role: "assistant", content: fullResponse))
            
            // Parse and execute actions
            let actions = parseActions(from: fullResponse)
            for action in actions {
                executeAction(action)
            }
            
            // Update streaming text one final time (clean version)
            streamingText = stripActionBlocks(from: fullResponse)
            isLoading = false
        } catch {
            lastError = error.localizedDescription
            isLoading = false
            // Remove the failed user message so it can be retried
            if conversationHistory.last?.role == "user" {
                conversationHistory.removeLast()
            }
        }
    }
    
    // MARK: - Action Parsing
    
    func parseActions(from response: String) -> [AIAction] {
        var actions: [AIAction] = []
        
        let pattern = "\\[ACTION\\]\\s*([\\s\\S]*?)\\s*\\[/ACTION\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return actions
        }
        
        let nsString = response as NSString
        let matches = regex.matches(in: response, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            guard match.numberOfRanges > 1 else { continue }
            let jsonString = nsString.substring(with: match.range(at: 1))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let jsonData = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                  let actionType = json["action"] as? String else { continue }
            
            switch actionType {
            case "create_task":
                if let taskDict = json["task"] as? [String: Any],
                   let taskData = parseTaskData(from: taskDict) {
                    actions.append(.createTask(taskData))
                }
                
            case "create_multiple":
                if let tasksArray = json["tasks"] as? [[String: Any]] {
                    let tasks = tasksArray.compactMap { parseTaskData(from: $0) }
                    if !tasks.isEmpty {
                        actions.append(.createMultipleTasks(tasks))
                    }
                }
                
            case "update_task":
                if let taskId = json["task_id"] as? String,
                   let taskDict = json["task"] as? [String: Any],
                   let taskData = parseTaskData(from: taskDict) {
                    actions.append(.updateTask(id: taskId, fields: taskData))
                }
                
            case "delete_task":
                if let taskId = json["task_id"] as? String {
                    actions.append(.deleteTask(id: taskId))
                }
                
            case "complete_task":
                if let taskId = json["task_id"] as? String {
                    actions.append(.completeTask(id: taskId))
                }
                
            default:
                break
            }
        }
        
        return actions
    }
    
    private func parseTaskData(from dict: [String: Any]) -> AITaskData? {
        guard let title = dict["title"] as? String else { return nil }
        return AITaskData(
            title: title,
            description: dict["description"] as? String,
            dueDate: dict["due_date"] as? String,
            startTime: dict["start_time"] as? String,
            endTime: dict["end_time"] as? String,
            priority: dict["priority"] as? String,
            eventType: dict["event_type"] as? String
        )
    }
    
    func stripActionBlocks(from text: String) -> String {
        let pattern = "\\[ACTION\\][\\s\\S]*?\\[/ACTION\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }
        return regex.stringByReplacingMatches(
            in: text,
            options: [],
            range: NSRange(location: 0, length: text.utf16.count),
            withTemplate: ""
        ).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Action Execution
    
    private func executeAction(_ action: AIAction) {
        guard let vm = todoViewModel else { return }
        
        switch action {
        case .createTask(let data):
            let task = buildTodoTask(from: data)
            vm.addEvent(task)
            executedActions.append("已创建: \(data.title)")
            
        case .createMultipleTasks(let dataList):
            for data in dataList {
                let task = buildTodoTask(from: data)
                vm.addEvent(task)
            }
            executedActions.append("已创建 \(dataList.count) 个任务")
            
        case .updateTask(let id, let fields):
            if let uuid = UUID(uuidString: id),
               var existing = vm.todos.first(where: { $0.id == uuid }) {
                applyUpdates(fields, to: &existing)
                vm.updateTodo(existing)
                executedActions.append("已更新: \(existing.title)")
            }
            
        case .deleteTask(let id):
            if let uuid = UUID(uuidString: id) {
                let title = vm.todos.first(where: { $0.id == uuid })?.title ?? "任务"
                vm.deleteTodoById(uuid)
                executedActions.append("已删除: \(title)")
            }
            
        case .completeTask(let id):
            if let uuid = UUID(uuidString: id),
               let task = vm.todos.first(where: { $0.id == uuid }) {
                if !task.isCompleted {
                    vm.toggleTodoCompletion(task)
                    executedActions.append("已完成: \(task.title)")
                }
            }
        }
    }
    
    private func buildTodoTask(from data: AITaskData) -> TodoTask {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dueDate = data.dueDate.flatMap { dateFormatter.date(from: $0) } ?? Date()
        
        var startTime: Date?
        var endTime: Date?
        
        if let startStr = data.startTime {
            let parts = startStr.split(separator: ":").compactMap { Int($0) }
            if parts.count >= 2 {
                startTime = calendar.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: dueDate)
            }
        }
        if let endStr = data.endTime {
            let parts = endStr.split(separator: ":").compactMap { Int($0) }
            if parts.count >= 2 {
                endTime = calendar.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: dueDate)
            }
        }
        
        let priority: TodoTask.TaskPriority = {
            switch data.priority?.lowercased() {
            case "high": return .high
            case "low": return .low
            default: return .medium
            }
        }()
        
        let eventType: TodoTask.EventType = {
            switch data.eventType?.lowercased() {
            case "gym": return .gym
            case "class": return .class_
            case "study": return .study
            case "meeting": return .meeting
            case "dinner": return .dinner
            default: return .other
            }
        }()
        
        return TodoTask(
            title: data.title,
            description: data.description ?? "",
            isCompleted: false,
            dueDate: dueDate,
            startTime: startTime,
            endTime: endTime,
            priority: priority,
            createdAt: Date(),
            eventType: eventType
        )
    }
    
    private func applyUpdates(_ data: AITaskData, to task: inout TodoTask) {
        task.title = data.title
        if let desc = data.description { task.description = desc }
        
        let calendar = Calendar.current
        if let dueDateStr = data.dueDate {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let d = df.date(from: dueDateStr) { task.dueDate = d }
        }
        if let startStr = data.startTime {
            let parts = startStr.split(separator: ":").compactMap { Int($0) }
            if parts.count >= 2 {
                task.startTime = calendar.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: task.dueDate)
            }
        }
        if let endStr = data.endTime {
            let parts = endStr.split(separator: ":").compactMap { Int($0) }
            if parts.count >= 2 {
                task.endTime = calendar.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: task.dueDate)
            }
        }
        if let p = data.priority?.lowercased() {
            switch p {
            case "high": task.priority = .high
            case "low": task.priority = .low
            default: task.priority = .medium
            }
        }
        if let e = data.eventType?.lowercased() {
            switch e {
            case "gym": task.eventType = .gym
            case "class": task.eventType = .class_
            case "study": task.eventType = .study
            case "meeting": task.eventType = .meeting
            case "dinner": task.eventType = .dinner
            default: task.eventType = .other
            }
        }
    }
    
    // MARK: - Reset
    
    func resetConversation() {
        conversationHistory = []
        streamingText = ""
        lastError = nil
        executedActions = []
    }
}
