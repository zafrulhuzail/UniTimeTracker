//
//  AbsenceTypePicker.swift
//  UniTimeTracker
//
//  Created by Zafrul Huzail Bin Mohd Zawahir on 25.04.25.
//


import SwiftUI

struct AbsenceTypePicker: View {
    @Binding var selectedType: AbsenceType
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(AbsenceType.allCases, id: \.self) { type in
                Button(action: {
                    selectedType = type
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(type.rawValue)
                        Spacer()
                        if type == selectedType {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select Absence Type")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}