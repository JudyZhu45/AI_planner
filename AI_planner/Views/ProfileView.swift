//
//  ProfileView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct ProfileView: View {
    var authManager: AuthManager
    @ObservedObject var viewModel: TodoViewModel
    
    /// Total hours planned across all events that have start/end times
    private var totalHoursPlanned: Double {
        viewModel.todos.reduce(0.0) { total, task in
            guard let start = task.startTime, let end = task.endTime else { return total }
            return total + end.timeIntervalSince(start) / 3600.0
        }
    }
    
    /// Number of completed tasks
    private var completedTasksCount: Int {
        viewModel.todos.filter { $0.isCompleted }.count
    }
    
    /// Current streak: consecutive days (ending today or yesterday) that have at least one completed task
    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Group completed tasks by day
        var daysWithCompletions = Set<Date>()
        for task in viewModel.todos where task.isCompleted {
            daysWithCompletions.insert(calendar.startOfDay(for: task.dueDate))
        }
        
        guard !daysWithCompletions.isEmpty else { return 0 }
        
        // Start counting from today, fall back to yesterday
        var checkDate = today
        if !daysWithCompletions.contains(checkDate) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            if !daysWithCompletions.contains(checkDate) {
                return 0
            }
        }
        
        var streak = 0
        while daysWithCompletions.contains(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        return streak
    }
    
    private var formattedHours: String {
        if totalHoursPlanned == 0 { return "0 hrs" }
        let rounded = (totalHoursPlanned * 10).rounded() / 10
        if rounded == rounded.rounded() {
            return "\(Int(rounded)) hrs"
        }
        return String(format: "%.1f hrs", rounded)
    }
    
    var body: some View {
        ZStack {
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Profile")
                        .font(AppTheme.Typography.displayMedium)
                        .foregroundColor(AppTheme.primaryDeepIndigo)
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.bgSecondary)
                .shadow(color: AppTheme.shadowColor, radius: 4, x: 0, y: 2)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
                        // Profile Card
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppTheme.secondaryTeal.opacity(0.3),
                                                AppTheme.primaryDeepIndigo.opacity(0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryDeepIndigo)
                            }
                            .frame(width: 100, height: 100)
                            
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Text(authManager.userEmail ?? "AI Planner User")
                                    .font(AppTheme.Typography.headlineSmall)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text("Organize your schedule with intelligence")
                                    .font(AppTheme.Typography.bodySmall)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.xl)
                        .background(AppTheme.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                .stroke(AppTheme.borderColor, lineWidth: 1)
                        )
                        .padding(AppTheme.Spacing.lg)
                        
                        // Stats
                        VStack(spacing: AppTheme.Spacing.md) {
                            SectionHeader(title: "Statistics", icon: "chart.bar.fill")
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            VStack(spacing: AppTheme.Spacing.md) {
                                ProfileStatRow(
                                    icon: "clock.fill",
                                    iconColor: AppTheme.secondaryTeal,
                                    label: "Total Hours Planned",
                                    value: formattedHours
                                )
                                
                                ProfileStatRow(
                                    icon: "checkmark.circle.fill",
                                    iconColor: Color.green.opacity(0.7),
                                    label: "Tasks Completed",
                                    value: "\(completedTasksCount) tasks"
                                )
                                
                                ProfileStatRow(
                                    icon: "flame.fill",
                                    iconColor: AppTheme.accentCoral,
                                    label: "Current Streak",
                                    value: "\(currentStreak) days"
                                )
                            }
                            .padding(AppTheme.Spacing.lg)
                            .background(AppTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                            .padding(AppTheme.Spacing.lg)
                        }
                        
                        // Settings
                        VStack(spacing: AppTheme.Spacing.md) {
                            SectionHeader(title: "Settings", icon: "gear")
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "bell.fill", label: "Notifications", value: "Enabled")
                                Divider()
                                    .foregroundColor(AppTheme.dividerColor)
                                SettingsRow(icon: "moon.fill", label: "Dark Mode", value: "Off")
                                Divider()
                                    .foregroundColor(AppTheme.dividerColor)
                                SettingsRow(icon: "lock.fill", label: "Privacy", value: "Configured")
                            }
                            .padding(AppTheme.Spacing.lg)
                            .background(AppTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .stroke(AppTheme.borderColor, lineWidth: 1)
                            )
                            .padding(AppTheme.Spacing.lg)
                        }
                        
                        // Sign Out
                        Button {
                            Task {
                                await authManager.signOut()
                            }
                        } label: {
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.accentCoral)
                                
                                Text("Sign Out")
                                    .font(AppTheme.Typography.titleMedium)
                                    .foregroundColor(AppTheme.accentCoral)
                                
                                Spacer()
                            }
                            .padding(AppTheme.Spacing.lg)
                            .background(AppTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .stroke(AppTheme.accentCoral.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        Spacer(minLength: AppTheme.Spacing.xxl)
                    }
                }
            }
        }
    }
}

// MARK: - Profile Stat Row
struct ProfileStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(value)
                    .font(AppTheme.Typography.headlineSmall)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.secondaryTeal)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(value)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textTertiary)
        }
    }
}

#Preview {
    ProfileView(authManager: AuthManager(), viewModel: .preview)
}
