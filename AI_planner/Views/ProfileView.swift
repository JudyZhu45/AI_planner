//
//  ProfileView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI
import UserNotifications

struct ProfileView: View {
    var authManager: AuthManager
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject private var calendarSync = CalendarSyncService.shared
    @State private var notificationsEnabled = false
    
    // MARK: - Computed Stats
    
    private var totalHoursPlanned: Double {
        viewModel.todos.reduce(0.0) { total, task in
            guard let start = task.startTime, let end = task.endTime else { return total }
            return total + end.timeIntervalSince(start) / 3600.0
        }
    }
    
    private var completedTasksCount: Int {
        viewModel.todos.filter { $0.isCompleted }.count
    }
    
    private var completionRate: Double {
        guard !viewModel.todos.isEmpty else { return 0 }
        return Double(completedTasksCount) / Double(viewModel.todos.count)
    }
    
    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var daysWithCompletions = Set<Date>()
        for task in viewModel.todos where task.isCompleted {
            daysWithCompletions.insert(calendar.startOfDay(for: task.dueDate))
        }
        
        guard !daysWithCompletions.isEmpty else { return 0 }
        
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
        if totalHoursPlanned == 0 { return "0" }
        let rounded = (totalHoursPlanned * 10).rounded() / 10
        if rounded == rounded.rounded() {
            return "\(Int(rounded))"
        }
        return String(format: "%.1f", rounded)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }
    
    var body: some View {
        ZStack {
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Profile")
                        .font(AppTheme.Typography.displayMedium)
                        .foregroundColor(AppTheme.primaryDeepIndigo)
                    
                    Spacer()
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.bgSecondary)
                .shadow(color: AppTheme.shadowColor, radius: 4, x: 0, y: 2)
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Profile Card
                        profileCard
                        
                        // Statistics
                        statisticsSection
                        
                        // Energy Curve
                        energyCurveSection
                        
                        // Settings
                        settingsSection
                        
                        // Sign Out
                        signOutButton
                        
                        Spacer(minLength: AppTheme.Spacing.xxl)
                    }
                    .padding(.top, AppTheme.Spacing.lg)
                }
            }
        }
        .task {
            await checkNotificationStatus()
        }
    }
    
    // MARK: - Profile Card
    
    private var profileCard: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Avatar
            Image("beaver-main")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppTheme.bgSecondary, lineWidth: 3)
                )
                .shadow(color: AppTheme.primaryDeepIndigo.opacity(0.15), radius: 8, x: 0, y: 4)
            
            VStack(spacing: AppTheme.Spacing.xs) {
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
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            SectionHeader(title: "Statistics", icon: "chart.bar.fill")
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            // 3-column stat cards
            HStack(spacing: AppTheme.Spacing.sm) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(completedTasksCount)",
                    label: "Completed",
                    color: Color.green
                )
                
                StatCard(
                    icon: "clock.fill",
                    value: formattedHours,
                    label: "Hours",
                    color: AppTheme.secondaryTeal
                )
                
                StatCard(
                    icon: "flame.fill",
                    value: "\(currentStreak)",
                    label: "Day Streak",
                    color: AppTheme.accentCoral
                )
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            
            // Completion rate bar
            VStack(spacing: AppTheme.Spacing.sm) {
                HStack {
                    Text("Completion Rate")
                        .font(AppTheme.Typography.titleMedium)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(completionRate * 100))%")
                        .font(AppTheme.Typography.titleMedium)
                        .foregroundColor(AppTheme.primaryDeepIndigo)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AppTheme.bgTertiary)
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppTheme.secondaryTeal,
                                        AppTheme.primaryDeepIndigo
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geo.size.width * completionRate), height: 10)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Text("\(completedTasksCount) of \(viewModel.todos.count) tasks")
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.textTertiary)
                    Spacer()
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .stroke(AppTheme.borderColor, lineWidth: 1)
            )
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }
    
    // MARK: - Energy Curve Section
    
    private var energyCurveSection: some View {
        let profile = EnergyAnalysisService.buildProfile(from: viewModel.todos)
        return EnergyCurveView(profile: profile)
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            SectionHeader(title: "Settings", icon: "gear")
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            VStack(spacing: 0) {
                // Calendar Sync Toggle
                SettingsToggleRow(
                    icon: "calendar.badge.clock",
                    label: "Sync to iOS Calendar",
                    subtitle: calendarSync.isAuthorized ? (calendarSync.isSyncEnabled ? "Enabled" : "Disabled") : "Not Authorized",
                    isOn: $calendarSync.isSyncEnabled
                )
                .onChange(of: calendarSync.isSyncEnabled) { _, newValue in
                    if newValue {
                        Task {
                            let granted = await calendarSync.requestAccess()
                            if granted {
                                viewModel.syncAllTasksToCalendar()
                            } else {
                                calendarSync.isSyncEnabled = false
                            }
                        }
                    } else {
                        viewModel.removeAllTasksFromCalendar()
                    }
                }
                
                Divider()
                    .padding(.leading, 48)
                
                // Notifications Toggle
                SettingsToggleRow(
                    icon: "bell.fill",
                    label: "Notifications",
                    subtitle: notificationsEnabled ? "Enabled" : "Disabled",
                    isOn: $notificationsEnabled
                )
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue {
                        Task {
                            let granted = await NotificationManager.shared.requestAuthorization()
                            if granted {
                                NotificationManager.shared.rescheduleAll(tasks: viewModel.todos)
                            } else {
                                notificationsEnabled = false
                            }
                        }
                    } else {
                        NotificationManager.shared.cancelAllNotifications()
                    }
                }
                
                Divider()
                    .padding(.leading, 48)
                
                // About row
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.secondaryTeal)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.secondaryTeal.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("About")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Text(appVersion)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.textTertiary)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .background(AppTheme.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .stroke(AppTheme.borderColor, lineWidth: 1)
            )
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }
    
    // MARK: - Sign Out
    
    private var signOutButton: some View {
        Button {
            Task {
                await authManager.signOut()
            }
        } label: {
            Text("Sign Out")
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.accentCoral)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.accentCoral.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                        .stroke(AppTheme.accentCoral.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // MARK: - Helpers
    
    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = settings.authorizationStatus == .authorized
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Color stripe
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(height: 3)
            
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .padding(.top, AppTheme.Spacing.xs)
            
            Text(value)
                .font(AppTheme.Typography.headlineLarge)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(label)
                .font(AppTheme.Typography.labelSmall)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.bottom, AppTheme.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .background(AppTheme.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .stroke(AppTheme.borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let label: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.secondaryTeal)
                .frame(width: 28, height: 28)
                .background(AppTheme.secondaryTeal.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(subtitle)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.secondaryTeal)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }
}

#Preview {
    ProfileView(authManager: AuthManager(), viewModel: .preview)
}
