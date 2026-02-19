//
//  TaskCard.swift
//  AI_planner
//
//  Created by Judy459 on 2/19/26.
//

import SwiftUI

struct TaskCard: View {
    let time: String
    let title: String
    let duration: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(time)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                Text(duration)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(width: 60, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16).fill(color))
        }
    }
}

#Preview {
    TaskCard(
        time: "8:00 AM",
        title: "Morning Gym",
        duration: "1 hour",
        color: Color(red: 0.85, green: 0.95, blue: 1.0)
    )
    .padding()
}
