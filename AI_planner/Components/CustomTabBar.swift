//
//  CustomTabBar.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(AppTheme.dividerColor)
            
            HStack(spacing: 0) {
                TabBarItem(
                    icon: "clock.fill",
                    label: "Today",
                    isSelected: selectedTab == 0,
                    action: { 
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 0 
                        }
                    }
                )
                
                Spacer()
                
                TabBarItem(
                    icon: "calendar.circle.fill",
                    label: "Calendar",
                    isSelected: selectedTab == 1,
                    action: { 
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 1 
                        }
                    }
                )
                
                Spacer()
                
                TabBarItem(
                    icon: "sparkles",
                    label: "AI Chat",
                    isSelected: selectedTab == 2,
                    action: { 
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 2 
                        }
                    }
                )
                
                Spacer()
                
                TabBarItem(
                    icon: "person.circle.fill",
                    label: "Profile",
                    isSelected: selectedTab == 3,
                    action: { 
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 3 
                        }
                    }
                )
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.bgSecondary)
            .shadow(color: AppTheme.shadowColor, radius: 8, x: 0, y: -4)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0))
}
