//
//  TodoViewModel.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import Foundation
import Combine
import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var todos: [TodoTask] = []
    @Published var showAddTodoSheet = false
    
    private let todosKey = "SavedTodos"
    
    init() {
        loadTodos()
        if todos.isEmpty {
            addSampleTodos()
        }
    }
    
    // MARK: - CRUD Operations
    
    func addTodo(title: String, description: String, dueDate: Date, priority: TodoTask.TaskPriority) {
        let newTodo = TodoTask(
            title: title,
            description: description,
            isCompleted: false,
            dueDate: dueDate,
            priority: priority,
            createdAt: Date()
        )
        todos.append(newTodo)
        saveTodos()
    }
    
    func updateTodo(_ todo: TodoTask) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveTodos()
        }
    }
    
    func deleteTodo(at indexSet: IndexSet) {
        todos.remove(atOffsets: indexSet)
        saveTodos()
    }
    
    func toggleTodoCompletion(_ todo: TodoTask) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            saveTodos()
        }
    }
    
    // MARK: - Data Management
    
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: todosKey)
        }
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: todosKey),
           let decoded = try? JSONDecoder().decode([TodoTask].self, from: data) {
            todos = decoded
        }
    }
    
    private func addSampleTodos() {
        let today = Date()
        let calendar = Calendar.current
        
        todos = [
            // Today's events
            TodoTask(
                title: "Gym",
                description: "Morning workout session",
                isCompleted: false,
                dueDate: today,
                startTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today),
                endTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today),
                priority: .medium,
                createdAt: today,
                eventType: .gym
            ),
            TodoTask(
                title: "Class",
                description: "Swift UI Advanced Techniques",
                isCompleted: false,
                dueDate: today,
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today),
                endTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today),
                priority: .high,
                createdAt: today,
                eventType: .class_
            ),
            TodoTask(
                title: "Study Session",
                description: "Review new concepts from class",
                isCompleted: false,
                dueDate: today,
                startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today),
                endTime: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: today),
                priority: .medium,
                createdAt: today,
                eventType: .study
            ),
            TodoTask(
                title: "Meeting",
                description: "Team standup meeting",
                isCompleted: false,
                dueDate: today,
                startTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: today),
                endTime: calendar.date(bySettingHour: 17, minute: 30, second: 0, of: today),
                priority: .high,
                createdAt: today,
                eventType: .meeting
            ),
            
            // Tomorrow's events
            TodoTask(
                title: "Gym",
                description: "Evening cardio workout",
                isCompleted: false,
                dueDate: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                startTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: today) ?? today),
                endTime: calendar.date(bySettingHour: 19, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 1, to: today) ?? today),
                priority: .medium,
                createdAt: today,
                eventType: .gym
            ),
            TodoTask(
                title: "Dinner",
                description: "Dinner with friends at the new Italian restaurant",
                isCompleted: false,
                dueDate: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                startTime: calendar.date(bySettingHour: 19, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 1, to: today) ?? today),
                endTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: today) ?? today),
                priority: .medium,
                createdAt: today,
                eventType: .dinner
            ),
            
            // Day 3
            TodoTask(
                title: "Class",
                description: "Data Structures and Algorithms",
                isCompleted: false,
                dueDate: calendar.date(byAdding: .day, value: 2, to: today) ?? today,
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 2, to: today) ?? today),
                endTime: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 2, to: today) ?? today),
                priority: .high,
                createdAt: today,
                eventType: .class_
            ),
            TodoTask(
                title: "Study Session",
                description: "Practice algorithm problems",
                isCompleted: false,
                dueDate: calendar.date(byAdding: .day, value: 2, to: today) ?? today,
                startTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 2, to: today) ?? today),
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 2, to: today) ?? today),
                priority: .high,
                createdAt: today,
                eventType: .study
            ),
            
            // Day 4
            TodoTask(
                title: "Meeting",
                description: "Project planning session",
                isCompleted: false,
                dueDate: calendar.date(byAdding: .day, value: 3, to: today) ?? today,
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 3, to: today) ?? today),
                endTime: calendar.date(bySettingHour: 11, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 3, to: today) ?? today),
                priority: .high,
                createdAt: today,
                eventType: .meeting
            ),
        ]
        saveTodos()
    }
    
    // MARK: - Helper Methods
    
    func getActiveTodosCount() -> Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    func getCompletedTodosCount() -> Int {
        todos.filter { $0.isCompleted }.count
    }
    
    func sortedTodos(by filter: TodoFilter) -> [TodoTask] {
        switch filter {
        case .all:
            return todos.sorted { $0.dueDate < $1.dueDate }
        case .active:
            return todos.filter { !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
        case .completed:
            return todos.filter { $0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
        }
    }
}

enum TodoFilter {
    case all
    case active
    case completed
}
