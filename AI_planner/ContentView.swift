//
//  ContentView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct ContentView: View {
    var authManager: AuthManager
    @State private var selectedTab = 0
    @StateObject private var todoViewModel = TodoViewModel()
    @State private var showAddEventSheet = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab content
                if selectedTab == 0 {
                    TodayView(viewModel: todoViewModel)
                } else if selectedTab == 1 {
                    CalendarView(viewModel: todoViewModel)
                } else if selectedTab == 2 {
                    AIChatView()
                } else {
                    ProfileView(authManager: authManager, viewModel: todoViewModel)
                }
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
            
            // Floating Action Button (Premium Design)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAddEventSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.textInverse)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppTheme.primaryDeepIndigo,
                                        AppTheme.primaryDeepIndigo.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: AppTheme.primaryDeepIndigo.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .padding(AppTheme.Spacing.xl)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showAddEventSheet) {
            AddEventSheet(viewModel: todoViewModel, isPresented: $showAddEventSheet)
        }
    }
}

#Preview {
    ContentView(authManager: AuthManager())
}
