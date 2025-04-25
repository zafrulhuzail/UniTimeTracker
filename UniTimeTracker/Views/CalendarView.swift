//
//  CalendarView.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//


import SwiftUI

/// Displays a interactive monthly calendar
///
/// - Features:
///   - Month navigation (previous/next)
///   - Visual indicators for:
///     - Selected date
///     - Completed entries
///     - Missing entries on working days
///
/// - Parameters:
///   - `selectedDate`: Binding to currently selected date
///
/// - Note: Automatically adjusts for different month lengths
struct CalendarView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var store: TimeStore
    
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: selectedDate))
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.bottom, 8)
            
            // Day headers
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                }
            }
            
            // Dates grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month) {
                        DayCell(date: date, selectedDate: $selectedDate)
                    } else {
                        DayCell(date: date, selectedDate: $selectedDate)
                            .opacity(0.3)
                    }
                }
            }
        }
    }
    
    private func DayCell(date: Date, selectedDate: Binding<Date>) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate.wrappedValue)
        let entry = store.entry(for: date)
        let isWorkingDay = store.settings.workingDays.contains(Calendar.current.component(.weekday, from: date))
        
        return Button(action: {
            selectedDate.wrappedValue = date
        }) {
            VStack {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if entry.isComplete {
                    Circle()
                        .fill(entry.absenceType != .none ? Color.orange : Color.green)
                        .frame(width: 6, height: 6)
                } else if isWorkingDay {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 32, height: 32)
            .background(isSelected ? Color.blue : Color.clear)
            .clipShape(Circle())
        }
    }
    
    private func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        let month = calendar.dateComponents([.year, .month], from: selectedDate)
        let start = calendar.date(from: month)!
        
        let range = calendar.range(of: .day, in: .month, for: start)!
        let startWeekday = calendar.component(.weekday, from: start)
        
        // Add days from previous month to fill first week
        var days: [Date] = []
        if startWeekday > 1 {
            let prevDays = startWeekday - 2
            if let prevMonth = calendar.date(byAdding: .month, value: -1, to: start) {
                let prevRange = calendar.range(of: .day, in: .month, for: prevMonth)!
                let startDay = prevRange.upperBound - prevDays
                for day in startDay..<prevRange.upperBound {
                    if let date = calendar.date(byAdding: .day, value: day, to: prevMonth) {
                        days.append(date)
                    }
                }
            }
        }
        
        // Add current month days
        for day in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: day, to: start) {
                days.append(date)
            }
        }
        
        // Add days from next month to fill last week
        let totalCells = days.count + (7 - (days.count % 7))
        let remaining = totalCells - days.count
        if remaining > 0, let nextMonth = calendar.date(byAdding: .month, value: 1, to: start) {
            for day in 0..<remaining {
                if let date = calendar.date(byAdding: .day, value: day, to: nextMonth) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    
    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
}
