//
//  TodoModel.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import Foundation
import SwiftUI

struct TodoTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var isCompleted: Bool
    var dueDate: Date
    var startTime: Date? // New: for calendar events
    var endTime: Date? // New: for calendar events
    var priority: TaskPriority
    var createdAt: Date
    var eventType: EventType = .other // New: categorize events
    
    enum TaskPriority: String, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: String {
            switch self {
            case .low:
                return "green"
            case .medium:
                return "yellow"
            case .high:
                return "red"
            }
        }
    }
    
    enum EventType: String, Codable {
        case gym = "Gym"
        case class_ = "Class"
        case study = "Study Session"
        case meeting = "Meeting"
        case dinner = "Dinner"
        case other = "Other"
    }
}
