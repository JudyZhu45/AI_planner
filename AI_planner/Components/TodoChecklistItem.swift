//
//  TodoChecklistItem.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

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

#Preview {
    let vm = TodoViewModel.preview
    TodoChecklistItem(
        task: vm.todos.first!,
        onToggle: {},
        onDelete: {}
    )
    .padding()
}
