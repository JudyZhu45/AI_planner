//
//  CalendarHelper.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import Foundation

struct CalendarHelper {
    static func getDaysInMonth(date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    static func getFirstDayOfMonth(date: Date) -> Int {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month], from: date)
        dateComponents.day = 1
        let firstDay = calendar.date(from: dateComponents)!
        let weekday = calendar.component(.weekday, from: firstDay)
        return weekday - 1
    }
    
    static func getMonthYearString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    static func getDayString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    static func getDateFromDay(_ day: Int, in month: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        var dateComponents = DateComponents()
        dateComponents.year = components.year
        dateComponents.month = components.month
        dateComponents.day = day
        return calendar.date(from: dateComponents)!
    }
    
    static func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    static func timeOnlyString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    static func getTasksForDay(_ tasks: [TodoTask], date: Date) -> [TodoTask] {
        return tasks.filter { isSameDay($0.dueDate, date) }
            .sorted { ($0.startTime ?? $0.dueDate) < ($1.startTime ?? $1.dueDate) }
    }
}
