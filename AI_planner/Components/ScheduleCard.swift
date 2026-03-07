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
    @State private var completionProgress: CGFloat = 0
    
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
                    Circle()
                        .fill(task.isCompleted ? AppTheme.bgTertiary : eventColor.primary.opacity(0.14))
                        .frame(width: 42, height: 42)

                    Image(systemName: eventColor.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(task.isCompleted ? AppTheme.textSecondary : eventColor.primary)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 17, weight: .bold))
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.bgSecondary.opacity(0.9))
                        .clipShape(Capsule())
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                        .fill(task.isCompleted ? AppTheme.bgSecondary.opacity(0.78) : AppTheme.bgElevated)

                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    eventColor.light.opacity(task.isCompleted ? 0.35 : 0.72),
                                    AppTheme.bgElevated
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Completion fill overlay
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppTheme.secondaryTeal.opacity(0.15),
                                        AppTheme.secondaryTeal.opacity(0.05)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * completionProgress)
                    }
                    .clipped()
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .stroke(task.isCompleted ? AppTheme.borderColor.opacity(0.85) : eventColor.primary.opacity(0.22), lineWidth: 1)
            )
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(color: AppTheme.Shadows.sm.color.opacity(isHovered ? 1 : 0.9), radius: isHovered ? 14 : 10, x: 0, y: isHovered ? 8 : 6)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onAppear {
            completionProgress = task.isCompleted ? 1.0 : 0.0
        }
        .onChange(of: task.isCompleted) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                completionProgress = newValue ? 1.0 : 0.0
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
