//
//  AppTheme.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

/**
 Comprehensive design system for AI Planner
 Color Palette: "Productive & Intelligent" - Modern premium aesthetic
 - Primary: Deep Indigo (trust, intelligence)
 - Secondary: Vibrant Teal (energy, innovation)
 - Accent: Warm Coral (urgency, action)
 */
struct AppTheme {
    // MARK: - Primary Colors (Core Brand)
    static let primaryDeepIndigo = Color(red: 0.20, green: 0.25, blue: 0.55) // Deep indigo for primary CTAs
    static let secondaryTeal = Color(red: 0.10, green: 0.65, blue: 0.75) // Vibrant teal for energy
    static let accentCoral = Color(red: 0.95, green: 0.45, blue: 0.40) // Warm coral for high priority
    
    // MARK: - Background Colors (Premium, Minimal)
    static let bgPrimary = Color(red: 0.98, green: 0.98, blue: 0.99) // Nearly white with blue tint
    static let bgSecondary = Color.white
    static let bgTertiary = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let bgElevated = Color(red: 0.99, green: 0.99, blue: 1.0)
    
    // MARK: - Text Colors
    static let textPrimary = Color(red: 0.08, green: 0.08, blue: 0.12)
    static let textSecondary = Color(red: 0.50, green: 0.50, blue: 0.55)
    static let textTertiary = Color(red: 0.75, green: 0.75, blue: 0.78)
    static let textInverse = Color.white
    
    // MARK: - Semantic Colors
    static let borderColor = Color(red: 0.90, green: 0.90, blue: 0.92)
    static let dividerColor = Color(red: 0.92, green: 0.92, blue: 0.94)
    static let shadowColor = Color.black.opacity(0.08)
    
    // MARK: - Event Type Colors (Rich, Saturated)
    static let eventColors: [EventColor] = [
        // Gym - Energetic Coral
        EventColor(
            name: "Gym",
            icon: "dumbbell.fill",
            light: Color(red: 0.99, green: 0.92, blue: 0.90),
            primary: Color(red: 0.95, green: 0.48, blue: 0.40),
            dark: Color(red: 0.80, green: 0.35, blue: 0.28)
        ),
        // Class - Academic Blue
        EventColor(
            name: "Class",
            icon: "book.fill",
            light: Color(red: 0.92, green: 0.95, blue: 0.99),
            primary: Color(red: 0.28, green: 0.60, blue: 0.92),
            dark: Color(red: 0.18, green: 0.45, blue: 0.80)
        ),
        // Study - Growth Green
        EventColor(
            name: "Study",
            icon: "pencil.circle.fill",
            light: Color(red: 0.94, green: 0.98, blue: 0.92),
            primary: Color(red: 0.45, green: 0.80, blue: 0.45),
            dark: Color(red: 0.30, green: 0.65, blue: 0.30)
        ),
        // Meeting - Professional Gold
        EventColor(
            name: "Meeting",
            icon: "person.2.fill",
            light: Color(red: 0.99, green: 0.96, blue: 0.92),
            primary: Color(red: 0.95, green: 0.70, blue: 0.35),
            dark: Color(red: 0.85, green: 0.58, blue: 0.20)
        ),
        // Dinner - Social Purple
        EventColor(
            name: "Dinner",
            icon: "fork.knife",
            light: Color(red: 0.96, green: 0.92, blue: 0.98),
            primary: Color(red: 0.70, green: 0.50, blue: 0.92),
            dark: Color(red: 0.55, green: 0.35, blue: 0.80)
        ),
        // Other - Neutral Gray
        EventColor(
            name: "Other",
            icon: "circle.fill",
            light: Color(red: 0.96, green: 0.96, blue: 0.97),
            primary: Color(red: 0.65, green: 0.65, blue: 0.68),
            dark: Color(red: 0.45, green: 0.45, blue: 0.50)
        ),
    ]
    
    // MARK: - Typography Scale
    enum Typography {
        static let displayLarge = Font.system(size: 32, weight: .bold)
        static let displayMedium = Font.system(size: 28, weight: .bold)
        static let headlineLarge = Font.system(size: 24, weight: .bold)
        static let headlineMedium = Font.system(size: 20, weight: .semibold)
        static let headlineSmall = Font.system(size: 18, weight: .semibold)
        
        static let titleLarge = Font.system(size: 16, weight: .semibold)
        static let titleMedium = Font.system(size: 14, weight: .semibold)
        static let titleSmall = Font.system(size: 12, weight: .semibold)
        
        static let bodyLarge = Font.system(size: 16, weight: .regular)
        static let bodyMedium = Font.system(size: 14, weight: .regular)
        static let bodySmall = Font.system(size: 12, weight: .regular)
        
        static let labelLarge = Font.system(size: 12, weight: .semibold)
        static let labelMedium = Font.system(size: 11, weight: .semibold)
        static let labelSmall = Font.system(size: 10, weight: .semibold)
    }
    
    // MARK: - Spacing System
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = .infinity
    }
    
    // MARK: - Shadows
    enum Shadows {
        static let xs = Shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        static let sm = Shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        static let md = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        static let lg = Shadow(color: .black.opacity(0.10), radius: 16, x: 0, y: 8)
        static let xl = Shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 12)
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

struct EventColor: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let light: Color // Light background
    let primary: Color // Primary color
    let dark: Color // Dark accent
    
    func getForType(_ type: TodoTask.EventType) -> EventColor {
        switch type {
        case .gym:
            return AppTheme.eventColors[0]
        case .class_:
            return AppTheme.eventColors[1]
        case .study:
            return AppTheme.eventColors[2]
        case .meeting:
            return AppTheme.eventColors[3]
        case .dinner:
            return AppTheme.eventColors[4]
        case .other:
            return AppTheme.eventColors[5]
        }
    }
}
