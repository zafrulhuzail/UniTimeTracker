//
//  DayView.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//


import SwiftUI

/// Detailed view for time entry on a specific date
///
/// - Features:
///   - Start/End time recording
///   - Break duration adjustment
///   - Absence type selection
///   - Notes field
///
/// - Parameters:
///   - `selectedDate`: Binding to currently selected date
///
/// - Important: Automatically differentiates between working and non-working days
struct DayView: View {
    @EnvironmentObject var store: TimeStore
    @Binding var selectedDate: Date
    
    @State private var showingAbsencePicker = false
    @State private var showingBreakTimePicker = false
    
    var entry: TimeEntry {
        store.entry(for: selectedDate)
    }
    
    var isWorkingDay: Bool {
        store.settings.workingDays.contains(Calendar.current.component(.weekday, from: selectedDate))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(dateFormatter.string(from: selectedDate))
                .font(.title)
            
            if entry.absenceType != .none {
                absenceView
            } else {
                timeEntryView
                breakTimeView
            }
            
            notesView
            
            Spacer()
            
            if entry.isComplete {
                Button("Clear Entry") {
                    clearEntry()
                }
                .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showingAbsencePicker) {
            AbsenceTypePicker(selectedType: Binding(
                get: { entry.absenceType },
                set: { updateEntry(absenceType: $0) }
            ))
        }
    }
    
    private var absenceView: some View {
        VStack {
            Text(entry.absenceType.rawValue)
                .font(.title2)
                .foregroundColor(.orange)
            
            Button("Change Absence Type") {
                showingAbsencePicker = true
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var timeEntryView: some View {
        VStack {
            if isWorkingDay {
                Text("Working Day")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    timeButton(title: "Start", time: entry.startTime) {
                        updateEntry(startTime: Date())
                    }
                    
                    timeButton(title: "End", time: entry.endTime) {
                        updateEntry(endTime: Date())
                    }
                }
            } else {
                Button("Mark as Absence") {
                    showingAbsencePicker = true
                }
            }
        }
    }
    
    private var breakTimeView: some View {
        Button(action: { showingBreakTimePicker = true }) {
            HStack {
                Text("Break Time:")
                Spacer()
                Text(timeFormatter.string(from: entry.breakDuration) ?? "0:00")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showingBreakTimePicker) {
            DurationPickerView(
                title: "Select Break Duration",
                duration: Binding(
                    get: { entry.breakDuration },
                    set: { updateEntry(breakDuration: $0) }
                )
            )
        }
    }
    
    private var notesView: some View {
        TextField("Notes", text: Binding(
            get: { entry.notes },
            set: { updateEntry(notes: $0) }
        ))
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    private func timeButton(title: String, time: Date?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.caption)
                Text(time.map { timeFormatter.string(from: $0) } ?? "--:--")
                    .font(.title2)
            }
            .frame(width: 100, height: 60)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private func updateEntry(
        startTime: Date? = nil,
        endTime: Date? = nil,
        breakDuration: TimeInterval? = nil,
        absenceType: AbsenceType? = nil,
        notes: String? = nil
    ) {
        var newEntry = entry
        if let startTime = startTime { newEntry.startTime = startTime }
        if let endTime = endTime { newEntry.endTime = endTime }
        if let breakDuration = breakDuration { newEntry.breakDuration = breakDuration }
        if let absenceType = absenceType { newEntry.absenceType = absenceType }
        if let notes = notes { newEntry.notes = notes }
        
        store.updateOrAddEntry(newEntry)
        
        Task {
            try await store.save()
        }
    }
    
    private func clearEntry() {
        store.updateOrAddEntry(TimeEntry(date: selectedDate))
        
        Task {
            try await store.save()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

extension DateFormatter {
    func string(from timeInterval: TimeInterval) -> String? {
        let date = Date(timeIntervalSinceReferenceDate: timeInterval)
        guard timeInterval > 0 else { return nil }
        return string(from: date)
    }
}
