//
//  TodayView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var showAddEventSheet = false
    
    // Get today's scheduled events (with time)
    var todayScheduledEvents: [TodoTask] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return viewModel.todos
            .filter { calendar.isDate($0.dueDate, inSameDayAs: today) }
            .filter { $0.startTime != nil && $0.endTime != nil }
            .sorted { ($0.startTime ?? Date()) < ($1.startTime ?? Date()) }
    }
    
    // Get today's todos (without specific time)
    var todayTodos: [TodoTask] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return viewModel.todos
            .filter { calendar.isDate($0.dueDate, inSameDayAs: today) }
            .filter { $0.startTime == nil }
            .sorted { !$0.isCompleted && $1.isCompleted }
    }
    
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: Date())
        
        formatter.dateFormat = "d MMMM"
        let dateString = formatter.string(from: Date())
        
        return "\(dayName), \(dateString)"
    }
    
    var completionPercentage: Int {
        guard !todayTodos.isEmpty else { return 0 }
        let completed = todayTodos.filter { $0.isCompleted }.count
        return Int(Double(completed) / Double(todayTodos.count) * 100)
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text(currentDateString)
                        .font(AppTheme.Typography.headlineLarge)
                        .foregroundColor(AppTheme.primaryDeepIndigo)
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        HStack {
                            Text("Today's Progress")
                                .font(AppTheme.Typography.titleSmall)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Spacer()
                            
                            Text("\(completionPercentage)%")
                                .font(AppTheme.Typography.labelLarge)
                                .foregroundColor(AppTheme.secondaryTeal)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                    .fill(AppTheme.bgTertiary)
                                
                                RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppTheme.secondaryTeal,
                                                AppTheme.secondaryTeal.opacity(0.7)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(completionPercentage) / 100)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.bgSecondary)
                .shadow(color: AppTheme.shadowColor, radius: 4, x: 0, y: 2)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        // Schedule Timeline Section
                        if !todayScheduledEvents.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                                SectionHeader(title: "Schedule", icon: "clock.fill")
                                
                                VStack(spacing: AppTheme.Spacing.md) {
                                    ForEach(todayScheduledEvents) { task in
                                        ScheduleCard(task: task)
                                    }
                                }
                            }
                            .padding(AppTheme.Spacing.lg)
                        }
                        
                        // Todo Checklist Section
                        if !todayTodos.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                                SectionHeader(title: "To Do", icon: "checklist")
                                
                                VStack(spacing: AppTheme.Spacing.md) {
                                    ForEach(todayTodos) { task in
                                        TodoChecklistItem(
                                            task: task,
                                            onToggle: {
                                                viewModel.toggleTodoCompletion(task)
                                            },
                                            onDelete: {
                                                if let index = viewModel.todos.firstIndex(where: { $0.id == task.id }) {
                                                    viewModel.deleteTodo(at: IndexSet(integer: index))
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(AppTheme.Spacing.lg)
                        }
                        
                        // Empty State
                        if todayScheduledEvents.isEmpty && todayTodos.isEmpty {
                            VStack(spacing: AppTheme.Spacing.lg) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.secondaryTeal.opacity(0.5))
                                
                                VStack(spacing: AppTheme.Spacing.sm) {
                                    Text("No tasks scheduled")
                                        .font(AppTheme.Typography.headlineSmall)
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Text("Tap the + button to add an event or task")
                                        .font(AppTheme.Typography.bodySmall)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                            .frame(maxHeight: .infinity)
                            .padding(AppTheme.Spacing.xxl)
                        }
                        
                        Spacer(minLength: AppTheme.Spacing.xxl)
                    }
                    .padding(.top, AppTheme.Spacing.lg)
                }
            }
        }
        .sheet(isPresented: $showAddEventSheet) {
            AddEventSheet(viewModel: viewModel, isPresented: $showAddEventSheet)
        }
    }
}

// MARK: - Todo Checklist Item
struct TodoChecklistItem: View {
    let task: TodoTask
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            CheckboxButton(
                isChecked: task.isCompleted,
                action: onToggle
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(task.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary)
                    .strikethrough(task.isCompleted)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .stroke(AppTheme.borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Filter Button Component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    isSelected ?
                    RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.2, green: 0.5, blue: 1.0))
                    : RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6))
                )
        }
    }
}

#Preview {
    TodayView()
}
