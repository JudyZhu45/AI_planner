//
//  TodayView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var showAddEventSheet = false
    @State private var editingEvent: TodoTask?
    @State private var editingTodo: TodoTask?
    
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
                
                // Use a List here so swipeActions work reliably on rows (left-swipe to reveal delete)
                List {
                    // Schedule Timeline Section
                    if !todayScheduledEvents.isEmpty {
                        Section(header: SectionHeader(title: "Schedule", icon: "clock.fill")) {
                            ForEach(todayScheduledEvents) { task in
                                ScheduleCard(
                                    task: task,
                                    onDelete: {
                                        if let index = viewModel.todos.firstIndex(where: { $0.id == task.id }) {
                                            viewModel.deleteTodo(at: IndexSet(integer: index))
                                        }
                                    }
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingEvent = task
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if let index = viewModel.todos.firstIndex(where: { $0.id == task.id }) {
                                            viewModel.deleteTodo(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }
                    }

                    // Todo Checklist Section
                    if !todayTodos.isEmpty {
                        Section(header: SectionHeader(title: "To Do", icon: "checklist")) {
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
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingTodo = task
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if let index = viewModel.todos.firstIndex(where: { $0.id == task.id }) {
                                            viewModel.deleteTodo(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }
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
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.top, AppTheme.Spacing.lg)
            }
        }
        .sheet(isPresented: $showAddEventSheet) {
            AddEventSheet(viewModel: viewModel, isPresented: $showAddEventSheet)
        }
        .sheet(item: $editingEvent) { task in
            AddEventSheet(
                viewModel: viewModel,
                isPresented: Binding(
                    get: { editingEvent != nil },
                    set: { if !$0 { editingEvent = nil } }
                ),
                editingTask: task
            )
        }
        .sheet(item: $editingTodo) { task in
            AddTodoSheet(viewModel: viewModel, editingTask: task)
        }
    }
}

#Preview {
    TodayView(viewModel: .preview)
}
