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

// MARK: - User Intent (NEW: AI-driven intent recognition)

enum UserIntent {
    case confirm      // User confirmed to execute
    case cancel       // User cancelled/rejected
    case clarify      // User wants to modify/clarify
    case neutral      // Normal conversation
}

// MARK: - Validation Result (NEW: Action validation)

enum ValidationResult {
    case valid
    case invalid(reason: String)
}

// MARK: - Action Result (for undo support)

struct ActionResult: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let taskId: UUID?
    let actionType: ActionResultType
    let undoData: UndoData?
    
    enum ActionResultType {
        case created, updated, deleted, completed, warning
    }
    
    enum UndoData {
        case deleteCreated(UUID)               // undo create → delete the task
        case restoreDeleted(TodoTask)          // undo delete → re-add the task
        case revertUpdate(TodoTask)            // undo update → restore old version
        case uncomplete(UUID)                  // undo complete → toggle back
    }
}

// MARK: - Chat Service

@MainActor
class ChatService: ObservableObject {
    @Published var isLoading = false
    @Published var streamingText = ""
    @Published var lastError: String?
    @Published var executedActions: [ActionResult] = []
    @Published var fallbackAssistantReply: String?
    
    private let api = KimiAPIService.shared
    private var conversationHistory: [KimiMessage] = []
    private let maxHistoryMessages = 20 // keep last 20 non-system messages
    
    // NEW: Track last user message for smart context
    private var lastUserMessage: String = ""
    
    // NEW: Recently mentioned task IDs for context retention
    private var recentlyMentionedTaskIds: [UUID] = []
    private let maxRecentTasks = 3
    
    weak var todoViewModel: TodoViewModel?
    
    init() {}
    
    // MARK: - System Prompt
    
    private func buildSystemPrompt(userMessage: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let currentTime = timeFormatter.string(from: Date())
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "zh_CN")
        weekdayFormatter.dateFormat = "EEEE"
        let weekday = weekdayFormatter.string(from: Date())
        
        let tasksContext = buildSmartContext(userMessage: userMessage)
    let conflictContext = buildConflictContext()
        let userProfileSummary = BehaviorAnalyzer.shared.generateProfileSummary(days: 30)
        let beaverPersona = BeaverPersonality.shared.personaPrompt(tasks: todoViewModel?.todos ?? [])
        let chatMemory = ChatMemoryStore.shared.generateMemorySummary()
        
        return """
        \(beaverPersona)
        
        You are also an intelligent schedule planning assistant integrated into a task management app. You can have natural conversations and directly manage the user's tasks.

        Current date: \(today) (\(weekday))
        Current time: \(currentTime)

        ## User Behavior Profile
        \(userProfileSummary)
        \(chatMemory.isEmpty ? "" : "\n        \(chatMemory)")

        ## Your Capabilities
        1. Natural conversation: Answer questions, give advice
        2. Create tasks: When the user asks to schedule something
        3. Update tasks: Modify details of existing tasks
        4. Delete tasks: Remove unwanted tasks
        5. Complete tasks: Mark tasks as completed
        6. Plan schedules: Create multiple tasks at once (daily/weekly plans)

        ## User's Current Tasks
        \(tasksContext)
        \(conflictContext.isEmpty ? "" : "\n        \(conflictContext)")

        ## Important Workflow (Must Follow Strictly)

        ### Execution Mode Decision
        Determine the execution mode based on user input:

        **Mode 1: Direct Execution (skip confirmation)**
        Output [ACTION] directly when any of these conditions are met:
        - User provides complete task information (e.g., "Schedule a meeting tomorrow from 3pm to 4pm")
        - User asks to complete or delete a specific existing task (by ID or clear title)
        - User modifies their own existing task (e.g., "Move tomorrow's 3pm meeting to 4pm")

        **Mode 2: Propose then Confirm**
        When any of these situations apply, propose a plan first and wait for confirmation:
        - User request is vague (e.g., "Help me plan tomorrow")
        - Batch operations involving multiple tasks
        - Operations that might overwrite or delete important data
        - AI needs to proactively schedule/recommend times (e.g., "Schedule some study time for me")

        ### Two-Step Confirmation Flow (for Mode 2)

        **Step 1: Propose a plan**
        Describe your proposal in natural language with a clear list format.
        End with something like: "If this looks good, reply 'confirm' and I'll add them right away."
        This step must NEVER include [ACTION] blocks.

        **Step 2: Execute after user confirms**
        When the user replies with confirmation intent, output [ACTION] blocks to execute.
        Also output the [INTENT]confirm[/INTENT] tag to indicate confirmation.

        ### Intent Recognition Tags (Important!)
        With each reply, identify the user's intent and output the corresponding tag:

        - User confirms execution → append at end: [INTENT]confirm[/INTENT]
        - User cancels/rejects → append at end: [INTENT]cancel[/INTENT]
        - User wants to modify/clarify → append at end: [INTENT]clarify[/INTENT]
        - Normal conversation or no clear intent → do not output INTENT tag

        Confirmation keywords: confirm, sure, ok, yes, go, do it, add, sounds good, perfect, go ahead
        Cancellation keywords: cancel, no, never mind, don't, stop, remove, skip

        ## ACTION Format (follow strictly, do not modify the format)

        Create a single task:
        [ACTION]
        {"action":"create_task","task":{"title":"Meeting","description":"Team standup","due_date":"2026-02-25","start_time":"15:00","end_time":"16:00","priority":"high","event_type":"meeting"}}
        [/ACTION]

        Create multiple tasks (for daily/weekly plans):
        [ACTION]
        {"action":"create_multiple","tasks":[{"title":"Gym","due_date":"2026-02-25","start_time":"08:00","end_time":"09:00","priority":"medium","event_type":"gym"},{"title":"Study","due_date":"2026-02-25","start_time":"10:00","end_time":"12:00","priority":"high","event_type":"study"}]}
        [/ACTION]

        Update a task:
        [ACTION]
        {"action":"update_task","task_id":"UUID","task":{"title":"New title","start_time":"14:00"}}
        [/ACTION]

        Delete a task:
        [ACTION]
        {"action":"delete_task","task_id":"UUID"}
        [/ACTION]

        Complete a task:
        [ACTION]
        {"action":"complete_task","task_id":"UUID"}
        [/ACTION]

        ## Rules
        - Always reply in the same language the user uses
        - JSON inside [ACTION] blocks must be on a single line, no line breaks
        - [INTENT] tags go at the very end of the reply, on their own line
        - Do not show JSON code in the conversation text; [ACTION] blocks are automatically hidden by the system
        - When creating timed events, both start_time and end_time are required
        - Use 24-hour format (HH:mm) and ISO date format (YYYY-MM-DD)
        - event_type options: gym, class, study, meeting, dinner, other
        - priority options: low, medium, high
        - "tomorrow" = the day after today \(today)
        - "next week" = starting from next Monday
        - When planning schedules, leave reasonable breaks/commute time between tasks
        - Use the app-provided conflict data below as the source of truth for existing overlaps
        - Check existing tasks to avoid creating additional time conflicts
        - If the user's request is unclear, ask for details before planning
        - Reference the user profile's peak hours and habits; prioritize important tasks during peak hours
        - If the user profile shows procrastination tendencies for certain task types, give gentle reminders
        - Strictly follow constraints and preferences from user preference memory (e.g., if "doesn't like waking up early", don't schedule morning tasks)
        - When the user expresses new preferences or habits, naturally acknowledge and remember them
        """
    }
    
    // MARK: - Smart Context (Dynamic prompt injection layer)
    
    private func buildSmartContext(userMessage: String) -> String {
        guard let vm = todoViewModel else { return "Task context unavailable. Local task store has not been connected yet." }
        if vm.todos.isEmpty { return "No tasks currently scheduled in local storage." }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let next7DaysEnd = calendar.date(byAdding: .day, value: 7, to: today) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let sorted = vm.todos.sorted {
            if $0.dueDate == $1.dueDate {
                return ($0.startTime ?? $0.dueDate) < ($1.startTime ?? $1.dueDate)
            }
            return $0.dueDate < $1.dueDate
        }
        
        let todayTasks = sorted.filter { calendar.isDate($0.dueDate, inSameDayAs: today) }
        let tomorrowTasks = sorted.filter { calendar.isDate($0.dueDate, inSameDayAs: tomorrow) }
        
        let mentionedDates = extractDatesFromMessage(userMessage)
        let mentionedDateTasks = sorted.filter { task in
            mentionedDates.contains(where: { calendar.isDate(task.dueDate, inSameDayAs: $0) })
                && !calendar.isDate(task.dueDate, inSameDayAs: today)
                && !calendar.isDate(task.dueDate, inSameDayAs: tomorrow)
        }
        
        let recentIDs = extractRecentlyMentionedTaskIDs(limit: 3)
        let recentTasks = sorted.filter { task in
            recentIDs.contains(task.id)
                && !calendar.isDate(task.dueDate, inSameDayAs: today)
                && !calendar.isDate(task.dueDate, inSameDayAs: tomorrow)
                && !mentionedDates.contains(where: { d in calendar.isDate(task.dueDate, inSameDayAs: d) })
        }
        
        let includedIDs = Set(todayTasks.map { $0.id })
            .union(tomorrowTasks.map { $0.id })
            .union(mentionedDateTasks.map { $0.id })
            .union(recentTasks.map { $0.id })
        let otherTasks = sorted.filter { !includedIDs.contains($0.id) }
        
        let incompleteTasks = sorted.filter { !$0.isCompleted }
        let overdueTasks = sorted.filter { !$0.isCompleted && $0.dueDate < today }
        let next7DaysTasks = sorted.filter {
            !$0.isCompleted && $0.dueDate >= today && $0.dueDate < next7DaysEnd
        }
        let completedTodayCount = sorted.filter {
            $0.isCompleted && ($0.completedAt.map { calendar.isDate($0, inSameDayAs: today) } ?? false)
        }.count
        
        var lines: [String] = []
        lines.append("Local task snapshot generated right before this request. Treat it as the source of truth for current app state.")
        lines.append("### Snapshot Summary")
        lines.append("- Total tasks: \(sorted.count)")
        lines.append("- Incomplete tasks: \(incompleteTasks.count)")
        lines.append("- Overdue tasks: \(overdueTasks.count)")
        lines.append("- Tasks due in next 7 days: \(next7DaysTasks.count)")
        lines.append("- Completed today: \(completedTodayCount)")
        
        appendTaskSection(
            title: "Today's Tasks (\(dateFormatter.string(from: today)))",
            tasks: todayTasks,
            lines: &lines,
            dateFormatter: dateFormatter,
            timeFormatter: timeFormatter,
            emptyMessage: "No tasks scheduled for today."
        )
        
        appendTaskSection(
            title: "Tomorrow's Tasks (\(dateFormatter.string(from: tomorrow)))",
            tasks: tomorrowTasks,
            lines: &lines,
            dateFormatter: dateFormatter,
            timeFormatter: timeFormatter,
            emptyMessage: "No tasks scheduled for tomorrow."
        )
        
        if !mentionedDateTasks.isEmpty {
            appendTaskSection(
                title: "Tasks on Dates Mentioned by the User",
                tasks: mentionedDateTasks,
                lines: &lines,
                dateFormatter: dateFormatter,
                timeFormatter: timeFormatter,
                emptyMessage: Optional<String>.none
            )
        }
        
        if !recentTasks.isEmpty {
            appendTaskSection(
                title: "Recently Discussed Tasks",
                tasks: recentTasks,
                lines: &lines,
                dateFormatter: dateFormatter,
                timeFormatter: timeFormatter,
                emptyMessage: Optional<String>.none
            )
        }
        
        if !otherTasks.isEmpty {
            lines.append("### Remaining Task Summary")
            let grouped = Dictionary(grouping: otherTasks) { calendar.startOfDay(for: $0.dueDate) }
            for date in grouped.keys.sorted() {
                let tasks = grouped[date, default: []]
                let incompleteCount = tasks.filter { !$0.isCompleted }.count
                let completedCount = tasks.count - incompleteCount
                lines.append("- \(dateFormatter.string(from: date)): \(tasks.count) task(s), \(incompleteCount) incomplete, \(completedCount) completed")
            }
        }
        
        return lines.joined(separator: "\n")
    }

    private func appendTaskSection(
        title: String,
        tasks: [TodoTask],
        lines: inout [String],
        dateFormatter: DateFormatter,
        timeFormatter: DateFormatter,
        emptyMessage: String?
    ) {
        lines.append("### \(title)")
        if tasks.isEmpty {
            if let emptyMessage {
                lines.append("- \(emptyMessage)")
            }
            return
        }
        
        for task in tasks {
            lines.append(formatTask(task, dateFormatter: dateFormatter, timeFormatter: timeFormatter))
        }
    }
    
    /// Extract dates referenced in user message (Chinese natural language + ISO format)
    private func extractDatesFromMessage(_ message: String) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        // Relative dates
        let relativeMap: [(String, Int)] = [
            ("今天", 0), ("明天", 1), ("后天", 2), ("大后天", 3)
        ]
        for (keyword, offset) in relativeMap {
            if message.contains(keyword), let d = calendar.date(byAdding: .day, value: offset, to: today) {
                dates.append(d)
            }
        }
        
        // 下周X
        let weekdayNames: [(String, Int)] = [
            ("下周一", 2), ("下周二", 3), ("下周三", 4), ("下周四", 5),
            ("下周五", 6), ("下周六", 7), ("下周日", 1)
        ]
        for (keyword, weekday) in weekdayNames {
            if message.contains(keyword) {
                var comps = DateComponents()
                comps.weekday = weekday
                if let nextDate = calendar.nextDate(after: today, matching: comps, matchingPolicy: .nextTime) {
                    let daysAhead = calendar.dateComponents([.day], from: today, to: nextDate).day ?? 0
                    if daysAhead <= 7 {
                        if let adjusted = calendar.date(byAdding: .day, value: 7, to: nextDate) {
                            dates.append(calendar.startOfDay(for: adjusted))
                        }
                    } else {
                        dates.append(calendar.startOfDay(for: nextDate))
                    }
                }
            }
        }
        
        // ISO format: 2026-03-05
        let isoPattern = "\\d{4}-\\d{2}-\\d{2}"
        if let regex = try? NSRegularExpression(pattern: isoPattern) {
            let nsString = message as NSString
            let matches = regex.matches(in: message, range: NSRange(location: 0, length: nsString.length))
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            for match in matches {
                let str = nsString.substring(with: match.range)
                if let d = df.date(from: str) { dates.append(calendar.startOfDay(for: d)) }
            }
        }
        
        // Chinese date: X月X日 / X月X号
        let cnPattern = "(\\d{1,2})月(\\d{1,2})[日号]"
        if let regex = try? NSRegularExpression(pattern: cnPattern) {
            let nsString = message as NSString
            let matches = regex.matches(in: message, range: NSRange(location: 0, length: nsString.length))
            for match in matches {
                if match.numberOfRanges >= 3 {
                    let month = Int(nsString.substring(with: match.range(at: 1))) ?? 0
                    let day = Int(nsString.substring(with: match.range(at: 2))) ?? 0
                    var comps = calendar.dateComponents([.year], from: today)
                    comps.month = month
                    comps.day = day
                    if let d = calendar.date(from: comps) { dates.append(calendar.startOfDay(for: d)) }
                }
            }
        }
        
        return dates
    }
    
    /// Extract task UUIDs mentioned in recent conversation history
    private func extractRecentlyMentionedTaskIDs(limit: Int = 3) -> Set<UUID> {
        guard let vm = todoViewModel else { return [] }
        let allIDs = Set(vm.todos.map { $0.id.uuidString })
        var found: [UUID] = []
        
        // Search recent messages (newest first)
        let recentMessages = conversationHistory.suffix(10).reversed()
        for msg in recentMessages {
            for idStr in allIDs {
                if msg.content.contains(idStr), let uuid = UUID(uuidString: idStr), !found.contains(uuid) {
                    found.append(uuid)
                    if found.count >= limit { return Set(found) }
                }
            }
        }
        return Set(found)
    }
    
    private func formatTask(_ task: TodoTask, dateFormatter: DateFormatter, timeFormatter: DateFormatter) -> String {
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
        return "- " + parts.joined(separator: " | ")
    }
    
    // MARK: - Send Message (Streaming)
    
    func sendMessage(_ userMessage: String) async {
        isLoading = true
        streamingText = ""
        lastError = nil
        executedActions = []
    fallbackAssistantReply = nil
        lastUserMessage = userMessage
        
        // Refresh system prompt with latest task context
        if conversationHistory.isEmpty {
            conversationHistory.append(KimiMessage(role: "system", content: buildSystemPrompt(userMessage: userMessage)))
        } else {
            conversationHistory[0] = KimiMessage(role: "system", content: buildSystemPrompt(userMessage: userMessage))
        }
        
        conversationHistory.append(KimiMessage(role: "user", content: userMessage))
        
        // Trim conversation to keep token usage manageable
        let messagesToSend = trimmedHistory()
        
        do {
            let stream = try await api.streamChat(messages: messagesToSend)
            var fullResponse = ""
            
            for try await chunk in stream {
                fullResponse += chunk
                streamingText = stripHiddenBlocks(from: fullResponse)
            }
            
            // Store full response in history
            conversationHistory.append(KimiMessage(role: "assistant", content: fullResponse))
            
            // NEW: Parse user intent from AI response
            _ = parseIntent(from: fullResponse)
            
            // NEW: Parse and validate actions before execution
            let actions = parseActions(from: fullResponse)
            let validatedActions = validateAndFilterActions(actions)
            
            for action in validatedActions {
                executeAction(action)
            }

            if !validatedActions.isEmpty,
               let fallbackAssistantReply,
               !fallbackAssistantReply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let displayResponse = stripHiddenBlocks(from: fullResponse)
                streamingText = [displayResponse, fallbackAssistantReply]
                    .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    .joined(separator: displayResponse.isEmpty ? "" : "\n\n")
            }
            
            // NEW: Update recently mentioned tasks
            updateRecentlyMentionedTasks(from: fullResponse)
            
            // Extract user preferences from conversation for long-term memory
            ChatMemoryStore.shared.extractPreferences(from: userMessage, aiResponse: fullResponse)
            
            // Update streaming text one final time (clean version)
            if streamingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                streamingText = stripHiddenBlocks(from: fullResponse)
            }
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
    
    // NEW: Parse user intent from AI response
    private func parseIntent(from response: String) -> UserIntent {
        if response.contains("[INTENT]confirm[/INTENT]") {
            return .confirm
        } else if response.contains("[INTENT]cancel[/INTENT]") {
            return .cancel
        } else if response.contains("[INTENT]clarify[/INTENT]") {
            return .clarify
        }
        return .neutral
    }
    
    // NEW: Validate actions before execution
    private func validateAndFilterActions(_ actions: [AIAction]) -> [AIAction] {
        return actions.compactMap { action -> AIAction? in
            switch validateAction(action) {
            case .valid:
                return action
            case .invalid(let reason):
                print("Action validation failed: \(reason)")
                executedActions.append(ActionResult(
                    icon: "exclamationmark.triangle.fill",
                    label: "Blocked: \(reason)",
                    taskId: nil,
                    actionType: .warning,
                    undoData: nil
                ))
                appendFallbackAssistantReply(for: action, reason: reason)
                return nil
            }
        }
    }
    
    // NEW: Validate individual action
    private func validateAction(_ action: AIAction) -> ValidationResult {
        switch action {
        case .createTask(let data):
            if case .invalid(let reason) = validateTaskData(data) {
                return .invalid(reason: reason)
            }
            return validateCreateConflict(for: data)
        case .createMultipleTasks(let dataList):
            var simulatedTasks: [TodoTask] = []
            for data in dataList {
                if case .invalid(let reason) = validateTaskData(data) {
                    return .invalid(reason: "Batch task '\(data.title)': \(reason)")
                }
                let simulatedTask = buildTodoTask(from: data)
                if let conflictReason = conflictReasonForTask(simulatedTask, additionalTasks: simulatedTasks, excludingTaskId: Optional<UUID>.none) {
                    return .invalid(reason: "Batch task '\(data.title)' conflicts: \(conflictReason)")
                }
                simulatedTasks.append(simulatedTask)
            }
            return .valid
        case .updateTask(let id, let data):
            if case .invalid(let reason) = validateTaskData(data) {
                return .invalid(reason: reason)
            }
            return validateUpdateConflict(taskId: id, data: data)
        case .deleteTask(let id):
            if UUID(uuidString: id) == nil {
                return .invalid(reason: "Invalid task ID: \(id)")
            }
            return .valid
        case .completeTask(let id):
            if UUID(uuidString: id) == nil {
                return .invalid(reason: "Invalid task ID: \(id)")
            }
            return .valid
        }
    }
    
    // NEW: Validate task data
    private func validateTaskData(_ data: AITaskData) -> ValidationResult {
        if data.title.trimmingCharacters(in: .whitespaces).isEmpty {
            return .invalid(reason: "Task title cannot be empty")
        }
        
        if data.title.count > 200 {
            return .invalid(reason: "Task title too long (max 200 characters)")
        }
        
        if let startStr = data.startTime, let endStr = data.endTime {
            let startParts = startStr.split(separator: ":").compactMap { Int($0) }
            let endParts = endStr.split(separator: ":").compactMap { Int($0) }
            
            if startParts.count >= 2 && endParts.count >= 2 {
                let startMinutes = startParts[0] * 60 + startParts[1]
                let endMinutes = endParts[0] * 60 + endParts[1]
                
                if startMinutes >= endMinutes {
                    return .invalid(reason: "End time must be later than start time")
                }
            }
        }
        
        return .valid
    }

    private func validateCreateConflict(for data: AITaskData) -> ValidationResult {
        let simulatedTask = buildTodoTask(from: data)
        if let reason = conflictReasonForTask(simulatedTask) {
            return .invalid(reason: "\"\(data.title)\" conflicts with an existing task: \(reason)")
        }
        return .valid
    }

    private func validateUpdateConflict(taskId: String, data: AITaskData) -> ValidationResult {
        guard let vm = todoViewModel,
              let uuid = UUID(uuidString: taskId),
              let existing = vm.todos.first(where: { $0.id == uuid }) else {
            return .invalid(reason: "Task to update was not found: \(taskId)")
        }

        var simulatedTask = existing
        applyUpdates(data, to: &simulatedTask)
        if let reason = conflictReasonForTask(simulatedTask, excludingTaskId: uuid) {
            return .invalid(reason: "Updated task \"\(simulatedTask.title)\" conflicts with an existing task: \(reason)")
        }
        return .valid
    }
    
    // NEW: Update recently mentioned tasks
    private func updateRecentlyMentionedTasks(from response: String) {
        let pattern = "ID: ([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        let matches = regex.matches(in: response, options: [], range: NSRange(location: 0, length: response.utf16.count))
        
        for match in matches {
            if let range = Range(match.range(at: 1), in: response) {
                let idString = String(response[range])
                if let uuid = UUID(uuidString: idString) {
                    recentlyMentionedTaskIds.removeAll { $0 == uuid }
                    recentlyMentionedTaskIds.insert(uuid, at: 0)
                }
            }
        }
        
        if recentlyMentionedTaskIds.count > maxRecentTasks {
            recentlyMentionedTaskIds = Array(recentlyMentionedTaskIds.prefix(maxRecentTasks))
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
    
    // OPTIMIZED: Strip both ACTION and INTENT blocks
    func stripHiddenBlocks(from text: String) -> String {
        var result = text
        
        // 1. Strip complete [ACTION]...[/ACTION] blocks
        let actionPattern = "\\[ACTION\\][\\s\\S]*?\\[/ACTION\\]"
        if let regex = try? NSRegularExpression(pattern: actionPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(location: 0, length: result.utf16.count),
                withTemplate: ""
            )
        }
        
        // 2. Strip incomplete [ACTION] block at the end (still streaming)
        let incompleteActionPattern = "\\[ACTION\\][\\s\\S]*$"
        if let regex = try? NSRegularExpression(pattern: incompleteActionPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(location: 0, length: result.utf16.count),
                withTemplate: ""
            )
        }
        
        // 3. Strip [INTENT]...[/INTENT] blocks
        let intentPattern = "\\[INTENT\\][\\s\\S]*?\\[/INTENT\\]"
        if let regex = try? NSRegularExpression(pattern: intentPattern, options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(location: 0, length: result.utf16.count),
                withTemplate: ""
            )
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Action Execution
    
    private func executeAction(_ action: AIAction) {
        guard let vm = todoViewModel else { return }
        
        switch action {
        case .createTask(let data):
            let task = buildTodoTask(from: data)
            vm.addEvent(task)
            executedActions.append(ActionResult(
                icon: "plus.circle.fill",
                label: "Created: \(data.title)",
                taskId: task.id,
                actionType: .created,
                undoData: .deleteCreated(task.id)
            ))
            // Check conflicts for newly created task
            let conflicts = checkActionConflicts(for: task.id)
            for (a, b) in conflicts {
                let other = a.id == task.id ? b : a
                executedActions.append(ActionResult(
                    icon: "exclamationmark.triangle.fill",
                    label: "⚠️ Conflict: \"\(task.title)\" & \"\(other.title)\"",
                    taskId: task.id,
                    actionType: .warning,
                    undoData: nil
                ))
            }
            
        case .createMultipleTasks(let dataList):
            var createdIds: [UUID] = []
            for data in dataList {
                let task = buildTodoTask(from: data)
                vm.addEvent(task)
                createdIds.append(task.id)
            }
            for (i, data) in dataList.enumerated() {
                executedActions.append(ActionResult(
                    icon: "plus.circle.fill",
                    label: "Created: \(data.title)",
                    taskId: createdIds[i],
                    actionType: .created,
                    undoData: .deleteCreated(createdIds[i])
                ))
            }
            // Check conflicts for all newly created tasks
            var reportedPairs: Set<String> = []
            for taskId in createdIds {
                let conflicts = checkActionConflicts(for: taskId)
                for (a, b) in conflicts {
                    let pairKey = [a.id.uuidString, b.id.uuidString].sorted().joined(separator: "-")
                    guard !reportedPairs.contains(pairKey) else { continue }
                    reportedPairs.insert(pairKey)
                    executedActions.append(ActionResult(
                        icon: "exclamationmark.triangle.fill",
                        label: "⚠️ Conflict: \"\(a.title)\" & \"\(b.title)\"",
                        taskId: taskId,
                        actionType: .warning,
                        undoData: nil
                    ))
                }
            }
            
        case .updateTask(let id, let fields):
            if let uuid = UUID(uuidString: id),
               let existing = vm.todos.first(where: { $0.id == uuid }) {
                let oldCopy = existing
                var updated = existing
                applyUpdates(fields, to: &updated)
                vm.updateTodo(updated)
                executedActions.append(ActionResult(
                    icon: "pencil.circle.fill",
                    label: "Updated: \(updated.title)",
                    taskId: uuid,
                    actionType: .updated,
                    undoData: .revertUpdate(oldCopy)
                ))
                // Check conflicts for updated task
                let conflicts = checkActionConflicts(for: uuid)
                for (a, b) in conflicts {
                    let other = a.id == uuid ? b : a
                    executedActions.append(ActionResult(
                        icon: "exclamationmark.triangle.fill",
                        label: "⚠️ Conflict: \"\(updated.title)\" & \"\(other.title)\"",
                        taskId: uuid,
                        actionType: .warning,
                        undoData: nil
                    ))
                }
            }
            
        case .deleteTask(let id):
            if let uuid = UUID(uuidString: id),
               let task = vm.todos.first(where: { $0.id == uuid }) {
                let copy = task
                vm.deleteTodoById(uuid)
                executedActions.append(ActionResult(
                    icon: "trash.circle.fill",
                    label: "Deleted: \(copy.title)",
                    taskId: uuid,
                    actionType: .deleted,
                    undoData: .restoreDeleted(copy)
                ))
            }
            
        case .completeTask(let id):
            if let uuid = UUID(uuidString: id),
               let task = vm.todos.first(where: { $0.id == uuid }) {
                if !task.isCompleted {
                    vm.toggleTodoCompletion(task)
                    executedActions.append(ActionResult(
                        icon: "checkmark.circle.fill",
                        label: "Completed: \(task.title)",
                        taskId: uuid,
                        actionType: .completed,
                        undoData: .uncomplete(uuid)
                    ))
                }
            }
        }
    }
    
    // MARK: - Undo
    
    func undoAction(_ result: ActionResult) {
        guard let vm = todoViewModel, let undoData = result.undoData else { return }
        
        switch undoData {
        case .deleteCreated(let id):
            vm.deleteTodoById(id)
        case .restoreDeleted(let task):
            vm.addEvent(task)
        case .revertUpdate(let oldTask):
            vm.updateTodo(oldTask)
        case .uncomplete(let id):
            if let task = vm.todos.first(where: { $0.id == id }), task.isCompleted {
                vm.toggleTodoCompletion(task)
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
    
    // MARK: - Conflict Detection
    
    /// Find all time-overlapping task pairs among given tasks using deterministic front-end logic.
    private func findConflicts(among tasks: [TodoTask]) -> [(TodoTask, TodoTask)] {
        let timed = tasks.filter { $0.startTime != nil && $0.endTime != nil && !$0.isCompleted }
        var conflicts: [(TodoTask, TodoTask)] = []
        let calendar = Calendar.current
        
        for i in 0..<timed.count {
            for j in (i + 1)..<timed.count {
                let a = timed[i], b = timed[j]
                // Must be same day
                guard calendar.isDate(a.dueDate, inSameDayAs: b.dueDate),
                      let startA = normalizedTaskStart(for: a), let endA = normalizedTaskEnd(for: a),
                      let startB = normalizedTaskStart(for: b), let endB = normalizedTaskEnd(for: b) else { continue }
                // Overlap: startA < endB && startB < endA
                if startA < endB && startB < endA {
                    conflicts.append((a, b))
                }
            }
        }
        return conflicts
    }
    
    /// Check if a specific task conflicts with any existing tasks
    private func checkActionConflicts(for taskId: UUID) -> [(TodoTask, TodoTask)] {
        guard let vm = todoViewModel,
              let target = vm.todos.first(where: { $0.id == taskId }) else { return [] }
        guard normalizedTaskStart(for: target) != nil,
              normalizedTaskEnd(for: target) != nil else { return [] }
        
        let others = vm.todos.filter { $0.id != taskId }
        let allRelevant = [target] + others
        return findConflicts(among: allRelevant).filter { $0.0.id == taskId || $0.1.id == taskId }
    }
    
    private func normalizedTaskStart(for task: TodoTask) -> Date? {
        let calendar = Calendar.current
        guard let startTime = task.startTime else { return nil }
        let components = calendar.dateComponents([.hour, .minute, .second], from: startTime)
        return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: components.second ?? 0, of: task.dueDate)
    }
    
    private func normalizedTaskEnd(for task: TodoTask) -> Date? {
        let calendar = Calendar.current
        guard let endTime = task.endTime else { return nil }
        let components = calendar.dateComponents([.hour, .minute, .second], from: endTime)
        return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: components.second ?? 0, of: task.dueDate)
    }

    private func conflictReasonForTask(
        _ task: TodoTask,
        additionalTasks: [TodoTask] = [],
        excludingTaskId: UUID? = nil
    ) -> String? {
        guard let vm = todoViewModel,
              let taskStart = normalizedTaskStart(for: task),
              let taskEnd = normalizedTaskEnd(for: task) else {
            return nil
        }

        let calendar = Calendar.current
        let candidates = (vm.todos + additionalTasks).filter {
            !$0.isCompleted &&
            $0.id != task.id &&
            $0.id != excludingTaskId &&
            calendar.isDate($0.dueDate, inSameDayAs: task.dueDate)
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        for candidate in candidates {
            guard let candidateStart = normalizedTaskStart(for: candidate),
                  let candidateEnd = normalizedTaskEnd(for: candidate) else { continue }

            if taskStart < candidateEnd && candidateStart < taskEnd {
                return "overlaps with \"\(candidate.title)\" (\(timeFormatter.string(from: candidateStart))-\(timeFormatter.string(from: candidateEnd))) on the same day"
            }
        }

        return nil
    }

    private func appendFallbackAssistantReply(for action: AIAction, reason: String) {
        switch action {
        case .createTask(let data):
            let task = buildTodoTask(from: data)
            fallbackAssistantReply = buildConflictProposalReply(for: task, reason: reason)
        case .updateTask(let id, let data):
            guard let vm = todoViewModel,
                  let uuid = UUID(uuidString: id),
                  let existing = vm.todos.first(where: { $0.id == uuid }) else {
                fallbackAssistantReply = buildGenericBlockedReply(reason: reason)
                return
            }
            var simulatedTask = existing
            applyUpdates(data, to: &simulatedTask)
            fallbackAssistantReply = buildConflictProposalReply(for: simulatedTask, reason: reason)
        case .createMultipleTasks(let dataList):
            let simulatedTasks = dataList.map(buildTodoTask(from:))
            fallbackAssistantReply = buildBatchConflictProposalReply(tasks: simulatedTasks, reason: reason)
        case .deleteTask, .completeTask:
            fallbackAssistantReply = buildGenericBlockedReply(reason: reason)
        }
    }

    private func buildGenericBlockedReply(reason: String) -> String {
        "I found a conflict with your current schedule, so I didn't execute this action yet.\n\nReason: \(reason)"
    }

    private func buildConflictProposalReply(for task: TodoTask, reason: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let conflictDescription = conflictDescriptionForTask(task) ?? reason
        let alternatives = suggestedAlternativeSlots(for: task, limit: 3)

        var lines: [String] = []
        lines.append("This plan conflicts with one of your current tasks, so I didn't create it yet.")
        lines.append("")
        lines.append("- Title: \(task.title)")
        lines.append("- Date: \(dateFormatter.string(from: task.dueDate))")
        if let start = normalizedTaskStart(for: task), let end = normalizedTaskEnd(for: task) {
            lines.append("- Time: \(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))")
        }
        lines.append("- Conflict: \(conflictDescription)")

        if !alternatives.isEmpty {
            lines.append("")
            lines.append("I can move it to one of these time slots:")
            for option in alternatives {
                lines.append("- \(option.label)")
            }
        } else {
            lines.append("")
            lines.append("I couldn't find a nearby available slot yet. If you want, give me a different time and I'll help schedule it.")
        }

        return lines.joined(separator: "\n")
    }

    private func buildBatchConflictProposalReply(tasks: [TodoTask], reason: String) -> String {
        let titles = tasks.map(\.title).joined(separator: ", ")
        return "There is a time conflict in this set of tasks, so I didn't create them yet.\n\nAffected tasks: \(titles)\nReason: \(reason)\n\nIf you'd like, I can help rearrange them into non-conflicting time slots."
    }

    private func conflictDescriptionForTask(_ task: TodoTask) -> String? {
        guard let vm = todoViewModel,
              let taskStart = normalizedTaskStart(for: task),
              let taskEnd = normalizedTaskEnd(for: task) else {
            return nil
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let calendar = Calendar.current

        for existing in vm.todos where !existing.isCompleted && existing.id != task.id {
            guard calendar.isDate(existing.dueDate, inSameDayAs: task.dueDate),
                  let existingStart = normalizedTaskStart(for: existing),
                  let existingEnd = normalizedTaskEnd(for: existing) else { continue }

            if taskStart < existingEnd && existingStart < taskEnd {
                return "It overlaps with \"\(existing.title)\" (\(timeFormatter.string(from: existingStart)) - \(timeFormatter.string(from: existingEnd)))."
            }
        }

        return nil
    }

    private struct SuggestedTimeSlot {
        let start: Date
        let end: Date

        var label: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }

    private func suggestedAlternativeSlots(for task: TodoTask, limit: Int) -> [SuggestedTimeSlot] {
        guard let vm = todoViewModel,
              let originalStart = normalizedTaskStart(for: task),
              let originalEnd = normalizedTaskEnd(for: task) else {
            return []
        }

        let duration = originalEnd.timeIntervalSince(originalStart)
        guard duration > 0 else { return [] }

        let calendar = Calendar.current
        let dayStart = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: task.dueDate) ?? calendar.startOfDay(for: task.dueDate)
        let dayEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: task.dueDate) ?? task.dueDate

        let busySlots = vm.todos
            .filter { !$0.isCompleted && calendar.isDate($0.dueDate, inSameDayAs: task.dueDate) && $0.id != task.id }
            .compactMap { existing -> SuggestedTimeSlot? in
                guard let start = normalizedTaskStart(for: existing),
                      let end = normalizedTaskEnd(for: existing) else { return nil }
                return SuggestedTimeSlot(start: start, end: end)
            }
            .sorted { $0.start < $1.start }

        var freeSlots: [SuggestedTimeSlot] = []
        var cursor = dayStart

        for busy in busySlots {
            if busy.start.timeIntervalSince(cursor) >= duration {
                freeSlots.append(SuggestedTimeSlot(start: cursor, end: cursor.addingTimeInterval(duration)))
            }
            if busy.end > cursor {
                cursor = busy.end
            }
        }

        if dayEnd.timeIntervalSince(cursor) >= duration {
            freeSlots.append(SuggestedTimeSlot(start: cursor, end: cursor.addingTimeInterval(duration)))
        }

        let sortedByProximity = freeSlots.sorted {
            abs($0.start.timeIntervalSince(originalStart)) < abs($1.start.timeIntervalSince(originalStart))
        }

        var deduped: [SuggestedTimeSlot] = []
        for slot in sortedByProximity {
            if deduped.contains(where: { $0.start == slot.start && $0.end == slot.end }) { continue }
            deduped.append(slot)
            if deduped.count >= limit { break }
        }

        return deduped
    }
    
    /// Build app-computed conflict context string for the system prompt.
    private func buildConflictContext() -> String {
        guard let vm = todoViewModel else { return "" }
        let conflicts = findConflicts(among: vm.todos)
        if conflicts.isEmpty { return "" }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: conflicts) { calendar.startOfDay(for: $0.0.dueDate) }
        
        var lines = [
            "## ⚠️ App-Detected Time Conflicts",
            "The following overlaps were computed by the app using deterministic time-range checks. Do not recalculate them; use them as trusted scheduling constraints."
        ]
        
        for date in grouped.keys.sorted() {
            lines.append("### \(dateFormatter.string(from: date))")
            for (a, b) in grouped[date, default: []].prefix(8) {
                let aStart = normalizedTaskStart(for: a).map { timeFormatter.string(from: $0) } ?? "?"
                let aEnd = normalizedTaskEnd(for: a).map { timeFormatter.string(from: $0) } ?? "?"
                let bStart = normalizedTaskStart(for: b).map { timeFormatter.string(from: $0) } ?? "?"
                let bEnd = normalizedTaskEnd(for: b).map { timeFormatter.string(from: $0) } ?? "?"
                lines.append("- \"\(a.title)\" (ID: \(a.id.uuidString), \(aStart)-\(aEnd)) overlaps with \"\(b.title)\" (ID: \(b.id.uuidString), \(bStart)-\(bEnd))")
            }
        }
        lines.append("Avoid these occupied intervals when proposing or creating new tasks. If needed, suggest moving one of the conflicting tasks.")
        return lines.joined(separator: "\n")
    }
    
    // MARK: - Reset
    
    func resetConversation() {
        conversationHistory = []
        streamingText = ""
        lastError = nil
        executedActions = []
        lastUserMessage = ""
        recentlyMentionedTaskIds = []
    }
    
    var conversationCount: Int {
        conversationHistory.filter { $0.role != "system" }.count
    }
    
    // MARK: - Context Trimming
    
    private func trimmedHistory() -> [KimiMessage] {
        guard conversationHistory.count > 1 else { return conversationHistory }
        
        let systemMessage = conversationHistory[0] // always system prompt
        let chatMessages = Array(conversationHistory.dropFirst())
        
        if chatMessages.count <= maxHistoryMessages {
            return conversationHistory
        }
        
        // Keep last N messages
        let trimmed = Array(chatMessages.suffix(maxHistoryMessages))
        return [systemMessage] + trimmed
    }
}
