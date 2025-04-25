//
//  DurationPickerView.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//


import SwiftUI

struct DurationPickerView: View {
    let title: String
    @Binding var duration: TimeInterval
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Picker("Hours", selection: $hours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)h").tag(hour)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)m").tag(minute)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                }
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        duration = TimeInterval(hours * 3600 + minutes * 60)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                hours = Int(duration) / 3600
                minutes = (Int(duration) % 3600) / 60
            }
        }
    }
}