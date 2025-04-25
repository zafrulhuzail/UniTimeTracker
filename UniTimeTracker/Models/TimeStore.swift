//
//  TimeStore.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//


import Foundation
import SwiftUI

/// Central data repository and persistence manager
///
/// - Responsibilities:
///   - Maintains array of `TimeEntry` records
///   - Manages `UserSettings`
///   - Handles data persistence
///   - Provides calculated summaries
///
/// - Important: All changes should be made through store methods
///   to ensure proper persistence
class TimeStore: ObservableObject {
    @Published var entries: [TimeEntry] = []
    @Published var settings = UserSettings.default
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
            .appendingPathComponent("timeEntries.data")
    }
    
    private static func settingsURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
            .appendingPathComponent("userSettings.data")
    }
    
    func load() async throws {
        let task = Task<[TimeEntry], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let entries = try JSONDecoder().decode([TimeEntry].self, from: data)
            return entries
        }
        
        let settingsTask = Task<UserSettings, Error> {
            let fileURL = try Self.settingsURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return UserSettings.default
            }
            return try JSONDecoder().decode(UserSettings.self, from: data)
        }
        
        let loadedEntries = try await task.value
        let loadedSettings = try await settingsTask.value
        
        DispatchQueue.main.async {
            self.entries = loadedEntries
            self.settings = loadedSettings
        }
    }
    
    func save() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(entries)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        
        let settingsTask = Task {
            let data = try JSONEncoder().encode(settings)
            let outfile = try Self.settingsURL()
            try data.write(to: outfile)
        }
        
        _ = try await task.value
        _ = try await settingsTask.value
    }
    
    func entry(for date: Date) -> TimeEntry {
        let calendar = Calendar.current
        let existing = entries.first {
            calendar.isDate($0.date, inSameDayAs: date)
        }
        return existing ?? TimeEntry(date: date)
    }
    
    func updateOrAddEntry(_ entry: TimeEntry) {
        if let index = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        entries.sort { $0.date < $1.date }
    }
    
    func monthlySummary(for month: Date) -> (worked: TimeInterval, expected: TimeInterval) {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        _ = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)!.count
        let workingDaysCount = (0..<daysInMonth).compactMap { day -> Date? in
            let date = calendar.date(byAdding: .day, value: day, to: monthStart)
            return date
        }.filter { date in
            let weekday = calendar.component(.weekday, from: date)
            return settings.workingDays.contains(weekday)
        }.count
        
        let expectedHours = Double(workingDaysCount) * (settings.contractHoursPerWeek / Double(settings.workingDays.count))
        
        let workedHours = entries.filter {
            calendar.isDate($0.date, equalTo: monthStart, toGranularity: .month)
        }.reduce(0) { total, entry in
            total + entry.workedDuration / 3600
        }
        
        return (worked: workedHours, expected: expectedHours)
    }
}
