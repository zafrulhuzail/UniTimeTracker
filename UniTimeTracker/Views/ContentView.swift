import SwiftUI

/// The main app view that coordinates all other views
///
/// - Subviews:
///   - `CalendarView`: Monthly calendar for date selection
///   - `DayView`: Detailed view for selected date
///   - `SettingsView`: User configuration
///   - `MonthSummaryView`: Monthly analytics
///
/// - Environment:
///   - Requires `TimeStore` environment object
struct ContentView: View {
    @EnvironmentObject var store: TimeStore
    @State private var selectedDate = Date()
    @State private var showingSettings = false
    @State private var showingMonthSummary = false
    
    var body: some View {
        NavigationView {
            VStack {
                CalendarView(selectedDate: $selectedDate)
                    .padding(.horizontal)
                
                DayView(selectedDate: $selectedDate)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Time Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingMonthSummary = true }) {
                        Image(systemName: "chart.bar")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingMonthSummary) {
                MonthSummaryView(month: selectedDate)
                    .environmentObject(store)
            }
            .task {
                do {
                    try await store.load()
                } catch {
                    print("Error loading data: \(error)")
                }
            }
        }
    }
}
