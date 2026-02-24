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
    
    private var isEditing: Bool { editingTask != nil }
    
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
                    TextField("Task Title", text: $title)
                    
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
                        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
                        if !trimmedTitle.isEmpty {
                            if var existing = editingTask {
                                existing.title = trimmedTitle
                                existing.description = description
                                existing.dueDate = dueDate
                                existing.priority = priority
                                viewModel.updateTodo(existing)
                            } else {
                                viewModel.addTodo(
                                    title: trimmedTitle,
                                    description: description,
                                    dueDate: dueDate,
                                    priority: priority
                                )
                            }
                            dismiss()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddTodoSheet(viewModel: .preview)
}
