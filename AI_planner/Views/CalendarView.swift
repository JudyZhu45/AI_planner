//
//  CalendarView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var todoViewModel = TodoViewModel()
    
    var body: some View {
        MindfulCalendarView(viewModel: todoViewModel)
    }
}

#Preview {
    CalendarView()
}
