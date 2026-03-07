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
    @State private var priority: TodoTask.TaskPriority = .medium
    @State private var showTitleWarning = false
    
    private var isEditing: Bool { editingTask != nil }
    
    private var isTitleEmpty: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var priorityOptions: [(todo: TodoTask.TaskPriority, title: String, icon: String, color: Color)] {
        [
            (.low, "Low", "leaf.fill", AppTheme.secondaryTeal),
            (.medium, "Medium", "circle.hexagongrid.fill", AppTheme.accentGold),
            (.high, "High", "flame.fill", AppTheme.accentCoral)
        ]
    }
    
    init(viewModel: TodoViewModel, editingTask: TodoTask? = nil) {
        self.viewModel = viewModel
        self.editingTask = editingTask
        
        if let task = editingTask {
            _title = State(initialValue: task.title)
            _description = State(initialValue: task.description)
            _priority = State(initialValue: task.priority)
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.bgSecondary,
                    AppTheme.bgPrimary,
                    AppTheme.bgTertiary.opacity(0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                        titleSection
                        descriptionSection
                        prioritySection

                        Spacer(minLength: AppTheme.Spacing.huge)
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            }
        }
    }

    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(AppTheme.Typography.titleSmall)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.bgElevated)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.borderColor.opacity(0.8), lineWidth: 1)
                    )
            }

            Spacer()

            Text(isEditing ? "Edit Task" : "New Task")
                .font(AppTheme.Typography.headlineSmall)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Button(action: saveTask) {
                HStack(spacing: 6) {
                    Text(isEditing ? "Save" : "Add")
                        .font(AppTheme.Typography.titleSmall)

                    if !isTitleEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                    }
                }
                .foregroundColor(AppTheme.textInverse)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    isTitleEmpty
                        ? AnyShapeStyle(AppTheme.primaryDeepIndigo.opacity(0.4))
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [AppTheme.primaryDeepIndigo, AppTheme.accentGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.bgElevated.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.borderColor.opacity(0.82), lineWidth: 1)
        )
        .shadow(color: AppTheme.Shadows.md.color, radius: AppTheme.Shadows.md.radius, x: AppTheme.Shadows.md.x, y: AppTheme.Shadows.md.y)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Task Title")
                .font(AppTheme.Typography.labelMedium)
                .foregroundColor(AppTheme.textSecondary)

            TextField("What would you like to get done?", text: $title)
                .font(AppTheme.Typography.bodyLarge)
                .foregroundColor(AppTheme.textPrimary)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .stroke(showTitleWarning && isTitleEmpty ? AppTheme.accentCoral : AppTheme.borderColor, lineWidth: 1)
                )
                .onChange(of: title) {
                    if !isTitleEmpty { showTitleWarning = false }
                }

            if showTitleWarning && isTitleEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Please enter a title")
                        .font(AppTheme.Typography.labelSmall)
                }
                .foregroundColor(AppTheme.accentCoral)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Description")
                .font(AppTheme.Typography.labelMedium)
                .foregroundColor(AppTheme.textSecondary)

            TextEditor(text: $description)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.textPrimary)
                .frame(height: 120)
                .padding(AppTheme.Spacing.sm)
                .background(AppTheme.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .stroke(AppTheme.borderColor, lineWidth: 1)
                )
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Priority")
                .font(AppTheme.Typography.labelMedium)
                .foregroundColor(AppTheme.textSecondary)

            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(priorityOptions, id: \.todo) { option in
                    Button {
                        priority = option.todo
                    } label: {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: option.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(priority == option.todo ? AppTheme.textInverse : option.color)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(priority == option.todo ? Color.white.opacity(0.18) : option.color.opacity(0.12))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                    .font(AppTheme.Typography.titleMedium)
                                    .foregroundColor(priority == option.todo ? AppTheme.textInverse : AppTheme.textPrimary)

                                Text(priorityDescription(for: option.todo))
                                    .font(AppTheme.Typography.bodySmall)
                                    .foregroundColor(priority == option.todo ? Color.white.opacity(0.82) : AppTheme.textSecondary)
                            }

                            Spacer()

                            if priority == option.todo {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(
                            priority == option.todo
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [option.color, AppTheme.primaryDeepIndigo.opacity(0.92)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                : AnyShapeStyle(AppTheme.bgElevated)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                                .stroke(priority == option.todo ? Color.white.opacity(0.1) : AppTheme.borderColor.opacity(0.85), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func priorityDescription(for priority: TodoTask.TaskPriority) -> String {
        switch priority {
        case .low:
            return "Flexible tasks you can fit in around your day."
        case .medium:
            return "Important enough to keep visible and scheduled."
        case .high:
            return "Needs attention soon and deserves priority focus."
        }
    }

    private func saveTask() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showTitleWarning = isTitleEmpty
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        if var existing = editingTask {
            existing.title = trimmedTitle
            existing.description = description
            existing.priority = priority
            viewModel.updateTodo(existing)
            ToastManager.shared.show("Task updated", type: .success)
        } else {
            viewModel.addTodo(
                title: trimmedTitle,
                description: description,
                dueDate: Date(),
                priority: priority
            )
            ToastManager.shared.show("Task added", type: .success)
        }
        dismiss()
    }
}

#Preview {
    AddTodoSheet(viewModel: .preview)
}
