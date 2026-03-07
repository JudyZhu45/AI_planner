//
//  TimeRecommendationEngine.swift
//  AI_planner
//
//  Created by AI Assistant on 3/4/26.
//

import Foundation

struct TimeRecommendation: Identifiable {
    let id = UUID()
    let startHour: Int
    let startMinute: Int
    let endHour: Int
    let endMinute: Int
    let confidence: Double      // 0.0-1.0
    let reason: String          // Explanation for the recommendation
    let conflictWarning: String? // Optional conflict note
    
    var startTimeString: String {
        String(format: "%02d:%02d", startHour, startMinute)
    }
    
    var endTimeString: String {
        String(format: "%02d:%02d", endHour, endMinute)
    }
    
    /// Create a Date for the start time on a given date
    func startDate(on date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: date) ?? date
    }
    
    /// Create a Date for the end time on a given date
    func endDate(on date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: date) ?? date
    }
}

class TimeRecommendationEngine {
    static let shared = TimeRecommendationEngine()
    
    private let analyzer = BehaviorAnalyzer.shared
    private let profileVM = UserProfileViewModel.shared
    
    private init() {}
    
    /// Generate time recommendations for a given event type, duration, and date
    func recommend(
        eventType: TodoTask.EventType,
        durationMinutes: Int = 60,
        date: Date,
        existingTasks: [TodoTask]
    ) -> [TimeRecommendation] {
        let profile = profileVM.profile
        guard profile.hasSufficientData else {
            return defaultRecommendations(eventType: eventType, durationMinutes: durationMinutes, date: date, existingTasks: existingTasks)
        }
        
        let calendar = Calendar.current
        
        // Get occupied time slots on this date
        let dayTasks = existingTasks.filter { calendar.isDate($0.dueDate, inSameDayAs: date) }
        let occupiedSlots = dayTasks.compactMap { task -> (start: Int, end: Int)? in
            guard let start = task.startTime, let end = task.endTime else { return nil }
            let sh = calendar.component(.hour, from: start) * 60 + calendar.component(.minute, from: start)
            let eh = calendar.component(.hour, from: end) * 60 + calendar.component(.minute, from: end)
            return (sh, eh)
        }
        
        // Get best hours for this event type from user profile
        let typePref = profile.taskTypePreferences[eventType.rawValue]
        let bestHours = typePref?.bestHours ?? profile.peakProductivityHours
        
        // Generate candidate slots (every 30 min from 6:00-22:00)
        var candidates: [(startMin: Int, endMin: Int, score: Double, reason: String, conflict: String?)] = []
        
        let slotStep = 30 // every 30 minutes
        for startMin in stride(from: 6 * 60, through: 22 * 60 - durationMinutes, by: slotStep) {
            let endMin = startMin + durationMinutes
            
            // Check for conflicts
            let hasConflict = occupiedSlots.contains { slot in
                startMin < slot.end && endMin > slot.start
            }
            
            if hasConflict { continue } // Skip conflicting slots
            
            let startHour = startMin / 60
            var score = 0.5 // base score
            var reasons: [String] = []
            
            // Boost: matches best hours for this event type
            if bestHours.contains(startHour) {
                score += 0.3
                if let rate = typePref?.completionRate, rate > 0 {
                    reasons.append("Your \(eventType.rawValue) completion rate is \(Int(rate * 100))% during this time")
                } else {
                    reasons.append("This is one of your most productive time slots")
                }
            }
            
            // Boost: matches peak productivity hours
            if profile.peakProductivityHours.contains(startHour) && !bestHours.contains(startHour) {
                score += 0.15
                reasons.append("This is your peak productivity period")
            }
            
            // Penalty: procrastination-prone hours
            let procrastinationTypes = profile.procrastinationPatterns
                .filter { $0.eventTypeRaw == eventType.rawValue && $0.deleteRate > 0.3 }
            if !procrastinationTypes.isEmpty {
                // Avoid scheduling during valley hours
                let energyProfile = EnergyAnalysisService.buildProfile(from: existingTasks)
                if energyProfile.procrastinationSlots.contains(startHour) {
                    score -= 0.2
                    reasons.append("You tend to procrastinate during this time — consider avoiding it")
                }
            }
            
            // Slight preference for morning slots for study/class
            if (eventType == .study || eventType == .class_) && startHour >= 8 && startHour <= 11 {
                score += 0.05
            }
            
            // Slight preference for evening for dinner
            if eventType == .dinner && startHour >= 17 && startHour <= 20 {
                score += 0.1
            }
            
            // Slight preference for afternoon/evening for gym
            if eventType == .gym && startHour >= 16 && startHour <= 19 {
                score += 0.05
            }
            
            // Check nearby conflicts (prefer slots with buffer)
            let nearbyConflict = occupiedSlots.contains { slot in
                let bufferStart = startMin - 15
                let bufferEnd = endMin + 15
                return bufferStart < slot.end && bufferEnd > slot.start
            }
            
            let conflictWarning: String? = nearbyConflict ? "Very close to another event" : nil
            if nearbyConflict { score -= 0.05 }
            
            let reason = reasons.isEmpty ? "This time slot is available" : reasons.first!
            
            candidates.append((startMin, endMin, min(1.0, max(0.0, score)), reason, conflictWarning))
        }
        
        // Sort by score and take top 3
        let top = candidates.sorted { $0.score > $1.score }.prefix(3)
        
        return top.map { candidate in
            TimeRecommendation(
                startHour: candidate.startMin / 60,
                startMinute: candidate.startMin % 60,
                endHour: candidate.endMin / 60,
                endMinute: candidate.endMin % 60,
                confidence: candidate.score,
                reason: candidate.reason,
                conflictWarning: candidate.conflict
            )
        }
    }
    
    /// Default recommendations when insufficient data
    private func defaultRecommendations(
        eventType: TodoTask.EventType,
        durationMinutes: Int,
        date: Date,
        existingTasks: [TodoTask]
    ) -> [TimeRecommendation] {
        let defaults: [(hour: Int, reason: String)] = {
            switch eventType {
            case .gym:
                return [(8, "Morning workout to start your day"), (17, "Afternoon exercise to unwind"), (19, "Evening workout to relieve stress")]
            case .class_:
                return [(9, "Morning focus is ideal for class"), (14, "Afternoon slot for lectures"), (10, "Mid-morning works well for learning")]
            case .study:
                return [(9, "Morning is the golden hour for studying"), (14, "Afternoon suits deep study"), (20, "Quiet evenings are great for review")]
            case .meeting:
                return [(10, "Morning meetings are more efficient"), (14, "Afternoon is good for team discussions"), (16, "Late afternoon for quick meetings")]
            case .dinner:
                return [(18, "Standard dinner time"), (19, "Slightly later dinner"), (17, "Early dinner")]
            case .other:
                return [(10, "Morning is efficient for errands"), (14, "Afternoon for daily tasks"), (16, "Late afternoon to wrap things up")]
            }
        }()
        
        let calendar = Calendar.current
        let dayTasks = existingTasks.filter { calendar.isDate($0.dueDate, inSameDayAs: date) }
        let occupiedSlots = dayTasks.compactMap { task -> (start: Int, end: Int)? in
            guard let start = task.startTime, let end = task.endTime else { return nil }
            let sh = calendar.component(.hour, from: start) * 60 + calendar.component(.minute, from: start)
            let eh = calendar.component(.hour, from: end) * 60 + calendar.component(.minute, from: end)
            return (sh, eh)
        }
        
        return defaults.compactMap { (hour, reason) in
            let startMin = hour * 60
            let endMin = startMin + durationMinutes
            
            let hasConflict = occupiedSlots.contains { slot in
                startMin < slot.end && endMin > slot.start
            }
            
            return TimeRecommendation(
                startHour: hour,
                startMinute: 0,
                endHour: endMin / 60,
                endMinute: endMin % 60,
                confidence: 0.4,
                reason: reason,
                conflictWarning: hasConflict ? "Conflicts with an existing event" : nil
            )
        }.filter { $0.conflictWarning == nil } // Only show non-conflicting defaults
    }
}
