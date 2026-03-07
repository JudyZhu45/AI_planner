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
    var onEdit: (() -> Void)? = nil
    @State private var completionProgress: CGFloat = 0
    
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
            .contentShape(Rectangle())
            .onTapGesture {
                onEdit?()
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                    .fill(AppTheme.bgElevated)

                RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.bgSecondary,
                                AppTheme.bgElevated
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                        .fill(AppTheme.secondaryTeal.opacity(0.08))
                        .frame(width: geo.size.width * completionProgress)
                }
                .clipped()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .stroke(AppTheme.borderColor.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: AppTheme.Shadows.xs.color, radius: AppTheme.Shadows.xs.radius, x: AppTheme.Shadows.xs.x, y: AppTheme.Shadows.xs.y)
        .onAppear {
            completionProgress = task.isCompleted ? 1.0 : 0.0
        }
        .onChange(of: task.isCompleted) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                completionProgress = newValue ? 1.0 : 0.0
            }
        }
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
