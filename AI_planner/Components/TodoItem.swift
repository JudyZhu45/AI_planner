//
//  TodoItem.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct TodoItem: View {
    let task: TodoTask
    @ObservedObject var viewModel: TodoViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Custom Checkbox
                Button(action: { viewModel.toggleTodoCompletion(task) }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(task.isCompleted ? Color(red: 0.2, green: 0.5, blue: 1.0) : .gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(task.isCompleted ? .gray : .black)
                        .strikethrough(task.isCompleted, color: .gray)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Priority Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 8, height: 8)
                    
                    Text(task.priority.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            
            // Due Date
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text(formatDate(task.dueDate))
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.leading, 32)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low:
            return Color.green.opacity(0.6)
        case .medium:
            return Color.yellow.opacity(0.6)
        case .high:
            return Color.red.opacity(0.6)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "MMM dd"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    let viewModel = TodoViewModel()
    TodoItem(
        task: TodoTask(
            title: "Finish project report",
            description: "Complete the Q1 project report and send to manager",
            isCompleted: false,
            dueDate: Date(),
            priority: .high,
            createdAt: Date()
        ),
        viewModel: viewModel
    )
    .padding()
}
