//
//  AddTodoSheet.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct AddTodoSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    var editingTask: TodoTask? = nil
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date(timeIntervalSinceNow: 86400) // Tomorrow
    @State private var priority: TodoTask.TaskPriority = .medium
    @State private var showTitleWarning = false
    
    private var isEditing: Bool { editingTask != nil }
    
    private var isTitleEmpty: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(viewModel: TodoViewModel, editingTask: TodoTask? = nil) {
        self.viewModel = viewModel
        self.editingTask = editingTask
        
        if let task = editingTask {
            _title = State(initialValue: task.title)
            _description = State(initialValue: task.description)
            _dueDate = State(initialValue: task.dueDate)
            _priority = State(initialValue: task.priority)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Task Title", text: $title)
                            .onChange(of: title) {
                                if !isTitleEmpty { showTitleWarning = false }
                            }
                        
                        if showTitleWarning && isTitleEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("Please enter a title")
                                    .font(.caption)
                            }
                            .foregroundColor(AppTheme.accentCoral)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(TodoTask.TaskPriority.low)
                        Text("Medium").tag(TodoTask.TaskPriority.medium)
                        Text("High").tag(TodoTask.TaskPriority.high)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Due Date")) {
                    DatePicker(
                        "Select Date",
                        selection: $dueDate,
                        displayedComponents: [.date]
                    )
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showTitleWarning = isTitleEmpty
                        }
                        
                        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
                        guard !trimmedTitle.isEmpty else { return }
                        
                        if var existing = editingTask {
                            existing.title = trimmedTitle
                            existing.description = description
                            existing.dueDate = dueDate
                            existing.priority = priority
                            viewModel.updateTodo(existing)
                            ToastManager.shared.show("Task updated", type: .success)
                        } else {
                            viewModel.addTodo(
                                title: trimmedTitle,
                                description: description,
                                dueDate: dueDate,
                                priority: priority
                            )
                            ToastManager.shared.show("Task added", type: .success)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddTodoSheet(viewModel: .preview)
}
