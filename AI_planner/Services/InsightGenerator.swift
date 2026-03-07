//
//  InsightGenerator.swift
//  AI_planner
//
//  Created by AI Assistant on 3/4/26.
//

import Foundation
import SwiftUI

// MARK: - Insight Models

enum InsightType: String, Codable {
    case completionMilestone
    case productivityTrend
    case timeRecommendation
    case procrastinationAlert
    case patternDiscovery
    case weeklyReview
}

struct InsightCard: Identifiable {
    let id = UUID()
    let type: InsightType
    let icon: String            // SF Symbol name
    let title: String           // Short title
    let description: String     // Detail description
    let color: Color            // Card accent color
    let priority: Int           // Higher = more important (for sorting)
    let createdAt: Date
}

// MARK: - Insight Generator

class InsightGenerator {
    static let shared = InsightGenerator()
    
    private let analyzer = BehaviorAnalyzer.shared
    private let store = UserBehaviorStore.shared
    private let dismissedKey = "DismissedInsightTypes"
    private let lastShownKey = "LastInsightShownDates"
    
    private init() {}
    
    /// Generate insights for display in TodayView
    func generateInsights(tasks: [TodoTask]) -> [InsightCard] {
        var insights: [InsightCard] = []
        let records = store.recentRecords(days: 30)
        
        guard records.count >= 5 else { return insights } // Need minimum data
        
        // 1. Completion milestone
        if let milestone = checkCompletionMilestone(tasks: tasks) {
            insights.append(milestone)
        }
        
        // 2. Productivity trend
        if let trend = checkProductivityTrend(tasks: tasks) {
            insights.append(trend)
        }
        
        // 3. Time recommendation
        if let timeRec = generateTimeRecommendationInsight(tasks: tasks) {
            insights.append(timeRec)
        }
        
        // 4. Procrastination alert
        if let alert = checkProcrastinationAlert(tasks: tasks) {
            insights.append(alert)
        }
        
        // 5. Pattern discovery
        if let pattern = discoverPattern(tasks: tasks) {
            insights.append(pattern)
        }
        
        // Sort by priority (highest first), limit to 3
        return insights.sorted { $0.priority > $1.priority }.prefix(3).map { $0 }
    }
    
    // MARK: - Insight Generators
    
    private func checkCompletionMilestone(tasks: [TodoTask]) -> InsightCard? {
        let profile = UserProfileViewModel.shared.profile
        let streak = profile.streakData.currentStreak
        
        // Streak milestones
        let milestones = [3, 7, 14, 21, 30]
        for m in milestones {
            if streak == m && !wasRecentlyShown(.completionMilestone, days: m) {
                markShown(.completionMilestone)
                return InsightCard(
                    type: .completionMilestone,
                    icon: "flame.fill",
                    title: "\(m)-day streak!",
                    description: streak >= 7 ? "Amazing! You've completed tasks for \(m) days in a row — keep it up!" : "Great start! \(m) days of completing tasks — keep going!",
                    color: AppTheme.accentCoral,
                    priority: 90,
                    createdAt: Date()
                )
            }
        }
        
        // Total completion milestones
        let totalCompleted = tasks.filter(\.isCompleted).count
        let totalMilestones = [10, 25, 50, 100, 200, 500]
        for m in totalMilestones {
            if totalCompleted == m && !wasRecentlyShown(.completionMilestone, days: 7) {
                markShown(.completionMilestone)
                return InsightCard(
                    type: .completionMilestone,
                    icon: "star.fill",
                    title: "\(m) tasks completed!",
                    description: "You've completed a total of \(m) tasks — you're on a roll!",
                    color: AppTheme.secondaryTeal,
                    priority: 85,
                    createdAt: Date()
                )
            }
        }
        
        return nil
    }
    
    private func checkProductivityTrend(tasks: [TodoTask]) -> InsightCard? {
        guard !wasRecentlyShown(.productivityTrend, days: 3) else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Compare this week vs last week completion
        guard let thisWeekStart = calendar.date(byAdding: .day, value: -7, to: today),
              let lastWeekStart = calendar.date(byAdding: .day, value: -14, to: today) else { return nil }
        
        let thisWeekCompleted = tasks.filter {
            $0.isCompleted && ($0.completedAt ?? $0.dueDate) >= thisWeekStart
        }.count
        
        let lastWeekCompleted = tasks.filter {
            $0.isCompleted && ($0.completedAt ?? $0.dueDate) >= lastWeekStart && ($0.completedAt ?? $0.dueDate) < thisWeekStart
        }.count
        
        guard lastWeekCompleted > 0 else { return nil }
        
        let changePercent = Int(Double(thisWeekCompleted - lastWeekCompleted) / Double(lastWeekCompleted) * 100)
        
        if changePercent > 10 {
            markShown(.productivityTrend)
            return InsightCard(
                type: .productivityTrend,
                icon: "arrow.up.right.circle.fill",
                title: "Productivity up \(changePercent)%",
                description: "You completed \(thisWeekCompleted) tasks this week, \(thisWeekCompleted - lastWeekCompleted) more than last week. Keep the momentum!",
                color: AppTheme.secondaryTeal,
                priority: 70,
                createdAt: Date()
            )
        } else if changePercent < -20 {
            markShown(.productivityTrend)
            return InsightCard(
                type: .productivityTrend,
                icon: "arrow.down.right.circle.fill",
                title: "Completions dipped this week",
                description: "You completed \(thisWeekCompleted) tasks this week, a bit fewer than last week. Try starting with easier tasks.",
                color: AppTheme.primaryDeepIndigo,
                priority: 60,
                createdAt: Date()
            )
        }
        
        return nil
    }
    
    private func generateTimeRecommendationInsight(tasks: [TodoTask]) -> InsightCard? {
        guard !wasRecentlyShown(.timeRecommendation, days: 5) else { return nil }
        
        let topHours = analyzer.topProductiveHours(days: 30)
        guard !topHours.isEmpty else { return nil }
        
        let hourStr = topHours.prefix(2).map { "\($0):00" }.joined(separator: " and ")
        markShown(.timeRecommendation)
        
        return InsightCard(
            type: .timeRecommendation,
            icon: "clock.badge.checkmark.fill",
            title: "Your peak hours",
            description: "Data shows you're most productive around \(hourStr). Schedule important tasks during these times.",
            color: AppTheme.secondaryTeal,
            priority: 50,
            createdAt: Date()
        )
    }
    
    private func checkProcrastinationAlert(tasks: [TodoTask]) -> InsightCard? {
        guard !wasRecentlyShown(.procrastinationAlert, days: 3) else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find overdue tasks
        let overdueTasks = tasks.filter {
            !$0.isCompleted && $0.dueDate < today
        }
        
        if overdueTasks.count >= 3 {
            // Group by event type
            let typeGroups = Dictionary(grouping: overdueTasks, by: \.eventType)
            if let (type, typeTasks) = typeGroups.max(by: { $0.value.count < $1.value.count }), typeTasks.count >= 2 {
                markShown(.procrastinationAlert)
                return InsightCard(
                    type: .procrastinationAlert,
                    icon: "exclamationmark.triangle.fill",
                    title: "\(typeTasks.count) \(type.rawValue) tasks overdue",
                    description: "You have \(typeTasks.count) overdue \(type.rawValue) tasks. Want to tackle the easiest one now?",
                    color: AppTheme.accentCoral,
                    priority: 80,
                    createdAt: Date()
                )
            }
        }
        
        return nil
    }
    
    private func discoverPattern(tasks: [TodoTask]) -> InsightCard? {
        guard !wasRecentlyShown(.patternDiscovery, days: 7) else { return nil }
        
        // Discover recurring time patterns
        let typeStats = analyzer.eventTypeAnalysis(days: 30)
        for stat in typeStats {
            if let avgHour = stat.avgCompletionHour, stat.completedCount >= 5 {
                let hourInt = Int(avgHour)
                if stat.completionRate > 0.7 {
                    markShown(.patternDiscovery)
                    return InsightCard(
                        type: .patternDiscovery,
                        icon: "lightbulb.fill",
                        title: "Found your \(stat.eventType.rawValue) pattern",
                        description: "You usually complete \(stat.eventType.rawValue) tasks around \(hourInt):00, with a \(Int(stat.completionRate * 100))% completion rate. Want to make this a regular time?",
                        color: AppTheme.primaryDeepIndigo,
                        priority: 40,
                        createdAt: Date()
                    )
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Dedup / Rate Limiting
    
    private func wasRecentlyShown(_ type: InsightType, days: Int) -> Bool {
        let key = "\(lastShownKey)_\(type.rawValue)"
        guard let lastDate = UserDefaults.standard.object(forKey: key) as? Date else { return false }
        let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        return daysSince < days
    }
    
    private func markShown(_ type: InsightType) {
        let key = "\(lastShownKey)_\(type.rawValue)"
        UserDefaults.standard.set(Date(), forKey: key)
    }
}
