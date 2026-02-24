//
//  AddEventSheet.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct AddEventSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: TodoViewModel
    var selectedDate: Date = Date()
    var editingTask: TodoTask? = nil
    
    @State private var title = ""
    @State private var description = ""
    @State private var eventDate: Date
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var selectedEventType: TodoTask.EventType = .other
    @State private var selectedPriority: TodoTask.TaskPriority = .medium
    
    private var isEditing: Bool { editingTask != nil }
    
    init(viewModel: TodoViewModel, isPresented: Binding<Bool>, selectedDate: Date = Date(), editingTask: TodoTask? = nil) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.selectedDate = selectedDate
        self.editingTask = editingTask
        
        if let task = editingTask {
            _title = State(initialValue: task.title)
            _description = State(initialValue: task.description)
            _eventDate = State(initialValue: task.dueDate)
            _startTime = State(initialValue: task.startTime ?? Date())
            _endTime = State(initialValue: task.endTime ?? Date())
            _selectedEventType = State(initialValue: task.eventType)
            _selectedPriority = State(initialValue: task.priority)
        } else {
            _eventDate = State(initialValue: selectedDate)
            let defaultStart = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            let defaultEnd = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
            _startTime = State(initialValue: defaultStart)
            _endTime = State(initialValue: defaultEnd)
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                            .font(AppTheme.Typography.titleSmall)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(isEditing ? "Edit Event" : "New Event")
                        .font(AppTheme.Typography.headlineSmall)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { saveEvent() }) {
                        Text("Save")
                            .font(AppTheme.Typography.titleSmall)
                            .foregroundColor(AppTheme.textInverse)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .background(AppTheme.primaryDeepIndigo)
                            .clipShape(Capsule())
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.lg)
                .background(AppTheme.bgSecondary)
                .shadow(color: AppTheme.shadowColor, radius: 4, x: 0, y: 2)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                        // Title Field
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Title")
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("Event name", text: $title)
                                .font(AppTheme.Typography.bodyLarge)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(AppTheme.Spacing.md)
                                .background(AppTheme.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                        }
                        
                        // Event Type Selector
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Event Type")
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.Spacing.md) {
                                    ForEach([TodoTask.EventType.gym, .class_, .study, .meeting, .dinner], id: \.self) { type in
                                        let eventColor = AppTheme.eventColors.first { $0.name.lowercased() == type.rawValue.lowercased() } ?? AppTheme.eventColors[5]
                                        
                                        Button(action: { selectedEventType = type }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: eventColor.icon)
                                                    .font(.system(size: 12, weight: .semibold))
                                                Text(type.rawValue)
                                                    .font(AppTheme.Typography.labelSmall)
                                            }
                                            .foregroundColor(selectedEventType == type ? AppTheme.textInverse : AppTheme.textSecondary)
                                            .padding(.vertical, AppTheme.Spacing.md)
                                            .padding(.horizontal, AppTheme.Spacing.lg)
                                            .background(selectedEventType == type ? eventColor.primary : AppTheme.bgSecondary)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .stroke(selectedEventType == type ? Color.clear : AppTheme.borderColor, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Date Field
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Date")
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "calendar.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppTheme.secondaryTeal)
                                
                                DatePicker(
                                    "Select date",
                                    selection: $eventDate,
                                    displayedComponents: .date
                                )
                                .font(AppTheme.Typography.bodyLarge)
                                .foregroundColor(AppTheme.textPrimary)
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(AppTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                        }
                        
                        // Start Time
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Start Time")
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "clock.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppTheme.secondaryTeal)
                                
                                DatePicker(
                                    "Start time",
                                    selection: $startTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .font(AppTheme.Typography.bodyLarge)
                                .foregroundColor(AppTheme.textPrimary)
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(AppTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                        }
                        
                        // End Time
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("End Time")
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "clock.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppTheme.accentCoral)
                                
                                DatePicker(
                                    "End time",
                                    selection: $endTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .font(AppTheme.Typography.bodyLarge)
                                .foregroundColor(AppTheme.textPrimary)
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(AppTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                        }
                        
                        // Notes Field
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Notes")
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextEditor(text: $description)
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(height: 100)
                                .padding(AppTheme.Spacing.sm)
                                .background(AppTheme.bgSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(AppTheme.borderColor, lineWidth: 1)
                                )
                        }
                        
                        Spacer()
                            .frame(height: AppTheme.Spacing.lg)
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            }
        }
    }
    
    func saveEvent() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        if var existing = editingTask {
            existing.title = trimmedTitle
            existing.description = description
            existing.dueDate = eventDate
            existing.startTime = startTime
            existing.endTime = endTime
            existing.eventType = selectedEventType
            existing.priority = selectedPriority
            viewModel.updateTodo(existing)
        } else {
            viewModel.addTodo(
                title: trimmedTitle,
                description: description,
                dueDate: eventDate,
                priority: selectedPriority
            )
            
            // Update the last added task with event details
            if let lastIndex = viewModel.todos.indices.last {
                var updatedTask = viewModel.todos[lastIndex]
                updatedTask.eventType = selectedEventType
                updatedTask.startTime = startTime
                updatedTask.endTime = endTime
                viewModel.updateTodo(updatedTask)
            }
        }
        
        isPresented = false
    }
}

#Preview {
    AddEventSheet(
        viewModel: .preview,
        isPresented: .constant(true),
        selectedDate: Date()
    )
}
