//
//  EnergyAnalysisService.swift
//  AI_planner
//
//  Created by Judy459 on 3/3/26.
//

import Foundation

struct EnergyDataPoint: Identifiable {
    let id = UUID()
    let hour: Int       // 0-23
    let value: Double   // 0.0-1.0 normalized energy level
}

struct EnergyProfile {
    let dataPoints: [EnergyDataPoint]  // 24 points, one per hour
    let peakHour: Int                  // Hour with highest energy
    let valleyHour: Int                // Hour with lowest energy
    let hasSufficientData: Bool        // Need at least 5 completed tasks with timestamps
}

class EnergyAnalysisService {
    
    /// Build energy profile from historical task completions
    static func buildProfile(from tasks: [TodoTask]) -> EnergyProfile {
        let completedTasks = tasks.filter { $0.completedAt != nil }
        let hasSufficientData = completedTasks.count >= 5
        
        // Build hourly histogram with priority weighting
        var hourlyScores = Array(repeating: 0.0, count: 24)
        let calendar = Calendar.current
        
        for task in completedTasks {
            guard let completedAt = task.completedAt else { continue }
            let hour = calendar.component(.hour, from: completedAt)
            let weight: Double = {
                switch task.priority {
                case .high: return 3.0
                case .medium: return 2.0
                case .low: return 1.0
                }
            }()
            hourlyScores[hour] += weight
        }
        
        // Apply 3-hour moving average for smoothing (circular)
        let windowSize = 3
        var smoothed = Array(repeating: 0.0, count: 24)
        for i in 0..<24 {
            var sum = 0.0
            for offset in -windowSize...windowSize {
                let idx = (i + offset + 24) % 24
                sum += hourlyScores[idx]
            }
            smoothed[i] = sum / Double(2 * windowSize + 1)
        }
        
        // Normalize to 0.0-1.0
        let maxVal = smoothed.max() ?? 1.0
        let minVal = smoothed.min() ?? 0.0
        let range = maxVal - minVal
        
        var normalized: [Double]
        if range > 0 {
            normalized = smoothed.map { ($0 - minVal) / range }
        } else {
            normalized = Array(repeating: hasSufficientData ? 0.5 : 0.0, count: 24)
        }
        
        // Build data points
        let dataPoints = (0..<24).map { hour in
            EnergyDataPoint(hour: hour, value: normalized[hour])
        }
        
        // Find peak and valley in waking hours (6-23)
        let wakingRange = 6..<23
        let peakHour = wakingRange.max(by: { normalized[$0] < normalized[$1] }) ?? 12
        let valleyHour = wakingRange.min(by: { normalized[$0] < normalized[$1] }) ?? 6
        
        return EnergyProfile(
            dataPoints: dataPoints,
            peakHour: peakHour,
            valleyHour: valleyHour,
            hasSufficientData: hasSufficientData
        )
    }
}
