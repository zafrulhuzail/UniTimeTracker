//
//  MonthSummaryView.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//


import SwiftUI

/// Analytics view showing monthly totals
///
/// - Displays:
///   - Worked vs expected hours
///   - Time balance (overtime/undertime)
///   - Absence breakdown
///   - Export options
///
/// - Parameters:
///   - `month`: Reference month to display
struct MonthSummaryView: View {
    @EnvironmentObject var store: TimeStore
    @Environment(\.presentationMode) var presentationMode
    
    let month: Date
    @State private var showingExportOptions = false
    
    var summary: (worked: TimeInterval, expected: TimeInterval) {
        store.monthlySummary(for: month)
    }
    
    var balance: TimeInterval {
        summary.worked - summary.expected
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Summary for \(monthFormatter.string(from: month))")) {
                    HStack {
                        Text("Worked Hours:")
                        Spacer()
                        Text("\(summary.worked, specifier: "%.1f") h")
                    }
                    
                    HStack {
                        Text("Expected Hours:")
                        Spacer()
                        Text("\(summary.expected, specifier: "%.1f") h")
                    }
                    
                    HStack {
                        Text("Balance:")
                        Spacer()
                        Text("\(balance, specifier: "%.1f") h")
                            .foregroundColor(balance >= 0 ? .green : .red)
                    }
                }
                
                Section(header: Text("Absences")) {
                    ForEach(AbsenceType.allCases.filter { $0 != .none }, id: \.self) { type in
                        let count = store.entries.filter {
                            Calendar.current.isDate($0.date, equalTo: month, toGranularity: .month) &&
                            $0.absenceType == type
                        }.count
                        
                        if count > 0 {
                            HStack {
                                Text(type.rawValue)
                                Spacer()
                                Text("\(count) day(s)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Monthly Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Export") {
                        showingExportOptions = true
                    }
                }
            }
            .actionSheet(isPresented: $showingExportOptions) {
                ActionSheet(
                    title: Text("Export Options"),
                    buttons: [
                        .default(Text("Export as CSV")) { exportAsCSV() },
                        .default(Text("Export as PDF")) { exportAsPDF() },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private func exportAsCSV() {
        // Implement CSV export
        print("Exporting as CSV")
    }
    
    private func exportAsPDF() {
        // Implement PDF export
        print("Exporting as PDF")
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
