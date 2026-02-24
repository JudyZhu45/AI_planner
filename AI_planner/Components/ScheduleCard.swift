//
//  ScheduleCard.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct ScheduleCard: View {
    let task: TodoTask
    let onDelete: (() -> Void)?
    @State private var isHovered = false
    
    var eventColor: EventColor {
        let eventType = task.eventType
        return AppTheme.eventColors.first(where: { $0.name.lowercased() == eventType.rawValue.lowercased() }) ?? AppTheme.eventColors.last!
    }
    
    var timeString: String {
        guard let startTime = task.startTime else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: startTime)
    }
    
    var durationString: String {
        guard let startTime = task.startTime, let endTime = task.endTime else { return "" }
        let duration = Int(endTime.timeIntervalSince(startTime) / 60)
        return "\(duration)m"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Icon Badge
                ZStack {
                    Image(systemName: eventColor.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textInverse)
                        .frame(width: 36, height: 36)
                        .background(task.isCompleted ? AppTheme.textTertiary : eventColor.primary)
                        .clipShape(Circle())
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.secondaryTeal)
                            .background(Circle().fill(AppTheme.bgSecondary).frame(width: 16, height: 16))
                            .offset(x: 14, y: -14)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(AppTheme.Typography.titleMedium)
                        .foregroundColor(task.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary)
                        .strikethrough(task.isCompleted)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(timeString)
                        .font(AppTheme.Typography.labelLarge)
                        .foregroundColor(task.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary)
                    
                    Text(durationString)
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(task.isCompleted ? eventColor.light.opacity(0.5) : eventColor.light)
            .cornerRadius(AppTheme.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .stroke(eventColor.primary.opacity(task.isCompleted ? 0.15 : 0.3), lineWidth: 1)
            )
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(color: eventColor.primary.opacity(isHovered ? 0.2 : 0.08), radius: isHovered ? 12 : 8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let sampleTask = TodoTask(
        title: "Gym",
        description: "Morning workout session",
        isCompleted: false,
        dueDate: today,
        startTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today),
        endTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today),
        priority: .medium,
        createdAt: today,
        eventType: .gym
    )
    
    VStack(spacing: AppTheme.Spacing.md) {
        ScheduleCard(task: sampleTask, onDelete: nil)
        
        let classTask = TodoTask(
            title: "Class",
            description: "Swift UI Advanced Techniques",
            isCompleted: false,
            dueDate: today,
            startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today),
            endTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today),
            priority: .high,
            createdAt: today,
            eventType: .class_
        )
        ScheduleCard(task: classTask, onDelete: nil)
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.bgPrimary)
}
