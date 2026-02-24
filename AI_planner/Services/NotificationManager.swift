//
//  NotificationManager.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Permission
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule a notification for a task. Events with startTime get a 15-min-before reminder.
    /// Todos without startTime get a morning reminder on the due date.
    func scheduleNotification(for task: TodoTask) {
        // Don't schedule for completed tasks or past dates
        guard !task.isCompleted else { return }
        
        // Cancel any existing notification for this task first
        cancelNotification(for: task)
        
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.sound = .default
        
        let calendar = Calendar.current
        var triggerDate: Date?
        
        if let startTime = task.startTime {
            // Event with start time: remind 15 minutes before
            content.body = task.description.isEmpty
                ? "Starting in 15 minutes"
                : "\(task.description) — Starting in 15 minutes"
            triggerDate = calendar.date(byAdding: .minute, value: -15, to: startTime)
        } else {
            // Todo without start time: remind at 8:00 AM on due date
            content.body = task.description.isEmpty
                ? "Due today"
                : "\(task.description) — Due today"
            triggerDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: task.dueDate)
        }
        
        guard let fireDate = triggerDate, fireDate > Date() else { return }
        
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    /// Cancel the notification for a specific task
    func cancelNotification(for task: TodoTask) {
        center.removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
    
    /// Cancel all scheduled notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// Reschedule notifications for all active tasks
    func rescheduleAll(tasks: [TodoTask]) {
        cancelAllNotifications()
        for task in tasks where !task.isCompleted {
            scheduleNotification(for: task)
        }
    }
}
