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
    @State private var fabOffset = CGSize.zero
    @State private var fabPosition = CGPoint(x: UIScreen.main.bounds.width - 48, y: 60)
    
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
                    AIChatView(viewModel: todoViewModel)
                } else {
                    ProfileView(authManager: authManager, viewModel: todoViewModel)
                }
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
            
            // Draggable Floating Action Button
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
                .position(x: fabPosition.x + fabOffset.width, y: fabPosition.y + fabOffset.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            fabOffset = value.translation
                        }
                        .onEnded { value in
                            fabPosition.x += value.translation.width
                            fabPosition.y += value.translation.height
                            fabOffset = .zero
                            
                            // Snap to screen edges
                            let screenWidth = UIScreen.main.bounds.width
                            let screenHeight = UIScreen.main.bounds.height
                            let padding: CGFloat = 48
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                // Snap to nearest horizontal edge
                                fabPosition.x = fabPosition.x < screenWidth / 2 ? padding : screenWidth - padding
                                // Clamp vertical position
                                fabPosition.y = max(60, min(screenHeight - 140, fabPosition.y))
                            }
                        }
                )
                .onTapGesture {
                    showAddEventSheet = true
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
