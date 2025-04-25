//
//  SettingsView.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//


import SwiftUI

/// User configuration interface
///
/// - Configurable Items:
///   - Personal information
///   - Contract details
///   - Working days selection
///   - Vacation allowance
///
/// - Note: Changes are automatically saved when dismissed
struct SettingsView: View {
    @EnvironmentObject var store: TimeStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var birthDate: Date = Date()
    @State private var contractHours: Double = 20
    @State private var vacationDays: Int = 30
    @State private var workingDays: [Int] = [2, 3, 4, 5, 6]
    
    let daysOfWeek = [
        (1, "Sunday"),
        (2, "Monday"),
        (3, "Tuesday"),
        (4, "Wednesday"),
        (5, "Thursday"),
        (6, "Friday"),
        (7, "Saturday")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                }
                
                Section(header: Text("Contract Details")) {
                    Stepper(value: $contractHours, in: 1...40, step: 0.5) {
                        Text("Contract Hours: \(contractHours, specifier: "%.1f") h/week")
                    }
                    
                    Stepper(value: $vacationDays, in: 0...60) {
                        Text("Vacation Days: \(vacationDays)")
                    }
                }
                
                Section(header: Text("Working Days")) {
                    ForEach(daysOfWeek, id: \.0) { day, name in
                        Toggle(isOn: Binding(
                            get: { workingDays.contains(day) },
                            set: { isOn in
                                if isOn {
                                    if !workingDays.contains(day) {
                                        workingDays.append(day)
                                    }
                                } else {
                                    workingDays.removeAll { $0 == day }
                                }
                            }
                        )) {
                            Text(name)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                name = store.settings.name
                birthDate = store.settings.birthDate
                contractHours = store.settings.contractHoursPerWeek
                vacationDays = store.settings.vacationDaysPerYear
                workingDays = store.settings.workingDays
            }
        }
    }
    
    private func saveSettings() {
        store.settings = UserSettings(
            name: name,
            birthDate: birthDate,
            contractHoursPerWeek: contractHours,
            workingDays: workingDays,
            vacationDaysPerYear: vacationDays,
            remainingVacationDays: store.settings.remainingVacationDays
        )
        
        Task {
            try await store.save()
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}
