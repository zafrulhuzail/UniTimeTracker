//
//  UserSettings.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//


import Foundation

/// Stores user configuration and contract details
///
/// - Parameters:
///   - name: User's full name
///   - birthDate: Date of birth
///   - contractHoursPerWeek: Agreed weekly working hours
///   - workingDays: Array of weekday numbers (1=Sunday to 7=Saturday)
///   - vacationDaysPerYear: Total annual vacation allowance
///   - remainingVacationDays: Current remaining vacation balance
///
/// - Note: Provides a static `default` configuration for initial setup
struct UserSettings: Codable {
    var name: String
    var birthDate: Date
    var contractHoursPerWeek: Double
    var workingDays: [Int] // 1=Sunday, 2=Monday, etc.
    var vacationDaysPerYear: Int
    var remainingVacationDays: Int
    
    static let `default` = UserSettings(
        name: "",
        birthDate: Date(),
        contractHoursPerWeek: 20,
        workingDays: [2, 3, 4, 5, 6], // Mon-Fri
        vacationDaysPerYear: 30,
        remainingVacationDays: 30
    )
}
