//
//  AppTheme.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

/**
 河狸日程 - 温暖木质设计系统
 Color Palette: "Warm & Natural" - 自然木质色系
 - Primary: Beaver Brown (河狸棕, 主色调)
 - Secondary: Moss Green (苔藓绿, 能量/完成)
 - Accent: Autumn Orange (秋橙, 强调/紧急)
 */
struct AppTheme {
    // MARK: - Primary Colors (河狸核心色)
    static let primaryDeepIndigo = Color(red: 0.490, green: 0.318, blue: 0.176) // 温暖深棕 #7D512D
    static let secondaryTeal = Color(red: 0.380, green: 0.616, blue: 0.478) // 森林绿 #619D7A
    static let accentCoral = Color(red: 0.867, green: 0.435, blue: 0.341) // 暖橙红 #DD6F57
    
    // MARK: - Background Colors (木质暖调)
    static let bgPrimary = Color(red: 0.969, green: 0.957, blue: 0.933) // 奶油暖白 #F7F4EE
    static let bgSecondary = Color(red: 0.996, green: 0.992, blue: 0.984) // 暖白 #FEFDFB
    static let bgTertiary = Color(red: 0.937, green: 0.925, blue: 0.898) // 浅驼色 #EFECE5
    static let bgElevated = Color(red: 0.988, green: 0.980, blue: 0.965) // 暖白提升
    
    // MARK: - Text Colors (棕调文字)
    static let textPrimary = Color(red: 0.200, green: 0.140, blue: 0.075) // 浓咖棕 #332413
    static let textSecondary = Color(red: 0.490, green: 0.408, blue: 0.310) // 暖灰棕 #7D684F
    static let textTertiary = Color(red: 0.655, green: 0.600, blue: 0.525) // 淡棕 #A79986
    static let textInverse = Color.white
    
    // MARK: - Semantic Colors (暖调语义色)
    static let borderColor = Color(red: 0.880, green: 0.855, blue: 0.810) // 暖灰边框 #E0DACF
    static let dividerColor = Color(red: 0.900, green: 0.878, blue: 0.840) // 暖灰分割 #E5E0D6
    static let shadowColor = Color(red: 0.200, green: 0.140, blue: 0.075).opacity(0.10) // 棕调阴影
    
    // MARK: - Event Type Colors (河狸自然色系)
    static let eventColors: [EventColor] = [
        // Gym - 陶土棕 (运动=力量)
        EventColor(
            name: "Gym",
            icon: "dumbbell.fill",
            light: Color(red: 0.965, green: 0.935, blue: 0.910),  // 浅陶土
            primary: Color(red: 0.690, green: 0.440, blue: 0.290), // 陶土棕
            dark: Color(red: 0.490, green: 0.300, blue: 0.180)     // 深陶土
        ),
        // Class - 湖蓝 (学习=清澈)
        EventColor(
            name: "Class",
            icon: "book.fill",
            light: Color(red: 0.918, green: 0.945, blue: 0.973),  // 浅湖蓝
            primary: Color(red: 0.340, green: 0.565, blue: 0.780), // 湖蓝
            dark: Color(red: 0.220, green: 0.420, blue: 0.630)     // 深湖蓝
        ),
        // Study - 森林绿 (研究=生长)
        EventColor(
            name: "Study",
            icon: "pencil.circle.fill",
            light: Color(red: 0.920, green: 0.957, blue: 0.930),  // 浅森绿
            primary: Color(red: 0.380, green: 0.616, blue: 0.478), // 森林绿
            dark: Color(red: 0.265, green: 0.470, blue: 0.350)     // 深森绿
        ),
        // Meeting - 蜂蜜黄 (会议=协作)
        EventColor(
            name: "Meeting",
            icon: "person.2.fill",
            light: Color(red: 0.975, green: 0.955, blue: 0.910),  // 浅蜂蜜
            primary: Color(red: 0.820, green: 0.650, blue: 0.380), // 蜂蜜黄
            dark: Color(red: 0.650, green: 0.490, blue: 0.250)     // 深蜂蜜
        ),
        // Dinner - 秋橙 (社交=温暖)
        EventColor(
            name: "Dinner",
            icon: "fork.knife",
            light: Color(red: 0.975, green: 0.930, blue: 0.915),  // 浅秋橙
            primary: Color(red: 0.867, green: 0.435, blue: 0.341), // 秋橙
            dark: Color(red: 0.700, green: 0.320, blue: 0.235)     // 深秋橙
        ),
        // Other - 暖石灰 (其他)
        EventColor(
            name: "Other",
            icon: "circle.fill",
            light: Color(red: 0.950, green: 0.940, blue: 0.925),  // 浅石灰
            primary: Color(red: 0.565, green: 0.510, blue: 0.440), // 暖石灰
            dark: Color(red: 0.420, green: 0.375, blue: 0.316)     // 深石灰
        ),
    ]
    
    // MARK: - Typography Scale (rounded 设计, 温暖亲和)
    enum Typography {
        static let displayLarge = Font.system(size: 32, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
        static let headlineLarge = Font.system(size: 24, weight: .bold, design: .rounded)
        static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
        
        static let titleLarge = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let titleMedium = Font.system(size: 14, weight: .semibold, design: .rounded)
        static let titleSmall = Font.system(size: 12, weight: .semibold, design: .rounded)
        
        static let bodyLarge = Font.system(size: 16, weight: .regular)
        static let bodyMedium = Font.system(size: 14, weight: .regular)
        static let bodySmall = Font.system(size: 12, weight: .regular)
        
        static let labelLarge = Font.system(size: 12, weight: .semibold, design: .rounded)
        static let labelMedium = Font.system(size: 11, weight: .semibold, design: .rounded)
        static let labelSmall = Font.system(size: 10, weight: .semibold, design: .rounded)
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
    
    // MARK: - Shadows (棕调阴影)
    enum Shadows {
        static let xs = Shadow(color: Color(red: 0.200, green: 0.140, blue: 0.075).opacity(0.05), radius: 2, x: 0, y: 1)
        static let sm = Shadow(color: Color(red: 0.200, green: 0.140, blue: 0.075).opacity(0.07), radius: 4, x: 0, y: 2)
        static let md = Shadow(color: Color(red: 0.200, green: 0.140, blue: 0.075).opacity(0.08), radius: 6, x: 0, y: 4)
        static let lg = Shadow(color: Color(red: 0.200, green: 0.140, blue: 0.075).opacity(0.10), radius: 15, x: 0, y: 10)
        static let xl = Shadow(color: Color(red: 0.200, green: 0.140, blue: 0.075).opacity(0.12), radius: 24, x: 0, y: 12)
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
