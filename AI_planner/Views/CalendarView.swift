//
//  CalendarView.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: TodoViewModel

    var body: some View {
        MindfulCalendarView(viewModel: viewModel)
    }
}

#Preview {
    CalendarView(viewModel: .preview)
}
