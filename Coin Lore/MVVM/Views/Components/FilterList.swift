//
//  FilterList.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 22/02/2025.
//


//
//  FilterList.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 22/02/2025.
//

import SwiftUI

struct FilterList: View {
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case selected = "Selected"
        case unselected = "Unselected"
    }
    
    @Binding var selectedFilter: FilterOption
    var onApply: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Spacer()
                
                Button(action: {
                    onApply()
                }) {
                    Text("Apply")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Filter Currencies")
        }
    }
}

// Preview
struct FilterList_Previews: PreviewProvider {
    static var previews: some View {
        FilterList(selectedFilter: .constant(.all), onApply: {})
    }
}
