//
//  CalendarSyncService.swift
//  AI_planner
//
//  Created by Judy459 on 3/3/26.
//

import Foundation
import EventKit
import Combine
import SwiftUI

@MainActor
class CalendarSyncService: ObservableObject {
    static let shared = CalendarSyncService()
    
    let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var isSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSyncEnabled, forKey: syncEnabledKey)
        }
    }
    
    private let syncEnabledKey = "CalendarSyncEnabled"
    
    private init() {
        isSyncEnabled = UserDefaults.standard.bool(forKey: syncEnabledKey)
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - Authorization
    
    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            return granted
        } catch {
            print("Calendar access request failed: \(error.localizedDescription)")
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            return false
        }
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .fullAccess
    }
    
    // MARK: - Sync Operations
    
    /// Save a TodoTask to the iOS Calendar. Returns the calendar event identifier.
    func saveToCalendar(_ task: TodoTask) -> String? {
        guard isAuthorized, isSyncEnabled else { return nil }
        
        let event: EKEvent
        
        // If task already has a calendar event, update it
        if let existingId = task.calendarEventId,
           let existingEvent = eventStore.event(withIdentifier: existingId) {
            event = existingEvent
        } else {
            event = EKEvent(eventStore: eventStore)
            event.calendar = eventStore.defaultCalendarForNewEvents
        }
        
        event.title = task.title
        event.notes = task.description.isEmpty ? nil : task.description
        
        if let startTime = task.startTime, let endTime = task.endTime {
            event.startDate = startTime
            event.endDate = endTime
        } else {
            // All-day event based on dueDate
            event.startDate = task.dueDate
            event.endDate = task.dueDate
            event.isAllDay = true
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            print("Failed to save event to calendar: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Remove a TodoTask from the iOS Calendar
    func removeFromCalendar(_ task: TodoTask) {
        guard isAuthorized else { return }
        guard let eventId = task.calendarEventId,
              let event = eventStore.event(withIdentifier: eventId) else { return }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
        } catch {
            print("Failed to remove event from calendar: \(error.localizedDescription)")
        }
    }
    
    /// Fetch iOS Calendar events for a date range and return them as TodoTasks
    func fetchCalendarEvents(from startDate: Date, to endDate: Date) -> [TodoTask] {
        guard isAuthorized, isSyncEnabled else { return [] }
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
        
        return ekEvents.map { ekEvent in
            TodoTask(
                title: ekEvent.title ?? "Untitled",
                description: ekEvent.notes ?? "",
                isCompleted: false,
                dueDate: ekEvent.startDate,
                startTime: ekEvent.isAllDay ? nil : ekEvent.startDate,
                endTime: ekEvent.isAllDay ? nil : ekEvent.endDate,
                priority: .medium,
                createdAt: Date(),
                eventType: .other,
                calendarEventId: ekEvent.eventIdentifier
            )
        }
    }
    
    /// Sync all existing app tasks to iOS Calendar
    func syncAllToCalendar(_ tasks: [TodoTask]) -> [TodoTask] {
        guard isAuthorized, isSyncEnabled else { return tasks }
        
        var updatedTasks = tasks
        for i in updatedTasks.indices {
            if let eventId = saveToCalendar(updatedTasks[i]) {
                updatedTasks[i].calendarEventId = eventId
            }
        }
        return updatedTasks
    }
    
    /// Remove all app events from iOS Calendar
    func removeAllFromCalendar(_ tasks: [TodoTask]) {
        for task in tasks {
            removeFromCalendar(task)
        }
    }
}
