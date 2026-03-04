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
    @State private var taskToDelete: TodoTask?
    @State private var showDeleteConfirmation = false
    @State private var showSwipeHint: Bool = !UserDefaults.standard.bool(forKey: "hasShownSwipeHint")
    
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
        let allTodayTasks = todayScheduledEvents + todayTodos
        guard !allTodayTasks.isEmpty else { return 0 }
        let completed = allTodayTasks.filter { $0.isCompleted }.count
        return Int(Double(completed) / Double(allTodayTasks.count) * 100)
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
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.4), value: completionPercentage)
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
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: completionPercentage)
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
                    // Swipe hint for first-time users
                    if showSwipeHint && (!todayScheduledEvents.isEmpty || !todayTodos.isEmpty) {
                        SwipeHintOverlay()
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                            .onDisappear { showSwipeHint = false }
                    }
                    
                    // Schedule Timeline Section
                    if !todayScheduledEvents.isEmpty {
                        Section(header: SectionHeader(title: "Schedule", icon: "clock.fill")) {
                            ForEach(todayScheduledEvents) { task in
                                ScheduleCard(
                                    task: task,
                                    onDelete: {
                                        taskToDelete = task
                                        showDeleteConfirmation = true
                                    }
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingEvent = task
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        taskToDelete = task
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                    .tint(AppTheme.accentCoral)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        viewModel.toggleTodoCompletion(task)
                                    } label: {
                                        Label(
                                            task.isCompleted ? "Undo" : "Complete",
                                            systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill"
                                        )
                                    }
                                    .tint(AppTheme.secondaryTeal)
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
                                        taskToDelete = task
                                        showDeleteConfirmation = true
                                    }
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingTodo = task
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        taskToDelete = task
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                    .tint(AppTheme.accentCoral)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        viewModel.toggleTodoCompletion(task)
                                    } label: {
                                        Label(
                                            task.isCompleted ? "Undo" : "Complete",
                                            systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill"
                                        )
                                    }
                                    .tint(AppTheme.secondaryTeal)
                                }
                            }
                        }
                    }

                    // Empty State
                    if todayScheduledEvents.isEmpty && todayTodos.isEmpty {
                        EmptyStateView(
                            icon: "sparkles",
                            title: "No tasks for today",
                            subtitle: "Start planning your day by adding events or tasks",
                            assetImage: "beaver-empty",
                            buttonTitle: "Add Event",
                            onAction: { showAddEventSheet = true }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
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
        .confirmationDialog(
            "Delete \"\(taskToDelete?.title ?? "")\"?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let task = taskToDelete,
                   let index = viewModel.todos.firstIndex(where: { $0.id == task.id }) {
                    let deletedTask = viewModel.todos[index]
                    viewModel.deleteTodo(at: IndexSet(integer: index))
                    ToastManager.shared.show("Task deleted", type: .error) {
                        // Undo: re-add the task
                        viewModel.addEvent(deletedTask)
                    }
                }
                taskToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                taskToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

#Preview {
    TodayView(viewModel: .preview)
}
