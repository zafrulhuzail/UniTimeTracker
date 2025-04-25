//
//  TimeEntry.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//

import Foundation

enum AbsenceType: String, CaseIterable, Codable {
    case none = "Working"
    case vacation = "Urlaub"
    case sick = "Krank"
    case training = "Fortbildung"
    case holiday = "Feiertag"
    case other = "Sonstige Freistellung"
}

/// Represents a single day's time tracking entry
///
/// - Parameters:
///   - id: Unique identifier for the entry
///   - date: The calendar date for this entry
///   - startTime: When work began (nil if not tracked)
///   - endTime: When work ended (nil if not tracked)
///   - breakDuration: Total break time in seconds
///   - absenceType: Type of absence if not working
///   - notes: Optional notes about the day
///
/// - Important: The `workedDuration` property automatically calculates
///   net working time by subtracting break duration from start-to-end time.
struct TimeEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var breakDuration: TimeInterval
    var absenceType: AbsenceType
    var notes: String
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         startTime: Date? = nil,
         endTime: Date? = nil,
         breakDuration: TimeInterval = 0,
         absenceType: AbsenceType = .none,
         notes: String = "") {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.breakDuration = breakDuration
        self.absenceType = absenceType
        self.notes = notes
    }
    
    var workedDuration: TimeInterval {
        guard let start = startTime, let end = endTime else { return 0 }
        return end.timeIntervalSince(start) - breakDuration
    }
    
    var isComplete: Bool {
        absenceType != .none || (startTime != nil && endTime != nil)
    }
}
