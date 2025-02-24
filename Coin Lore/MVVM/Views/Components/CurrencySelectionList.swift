import SwiftUI

struct CurrencySelectionList: View {
    @ObservedObject var viewModel: StatisticsViewModel
    var onDone: () -> Void

    @State private var sortOrder: Bool = true
    @State private var selectedFilter: FilterOption = .all
    @State private var searchText: String = ""

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case selected = "Selected"
        case unselected = "Unselected"

        var next: FilterOption {
            switch self {
            case .all: return .selected
            case .selected: return .unselected
            case .unselected: return .all
            }
        }

        var icon: String {
            switch self {
            case .all: return "line.3.horizontal.circle"
            case .selected: return "checkmark.circle.fill"
            case .unselected: return "circle"
            }
        }
    }

    var filteredCurrencies: [String] {
        let sortedList = sortOrder ? viewModel.filteredAvailableCurrencies.sorted() : viewModel.filteredAvailableCurrencies.sorted(by: >)

        let filteredList: [String]
        switch selectedFilter {
        case .all:
            filteredList = sortedList
        case .selected:
            filteredList = sortedList.filter { viewModel.selectedCurrencies.contains($0) }
        case .unselected:
            filteredList = sortedList.filter { !viewModel.selectedCurrencies.contains($0) }
        }

        return filteredList.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText)

                if filteredCurrencies.isEmpty {
                    VStack {
                        Spacer()
                        Text("No currencies available")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List(filteredCurrencies, id: \.self) { currency in
                        HStack {
                            Text(currency)
                                .font(.body)

                            Spacer()

                            if viewModel.selectedCurrencies.contains(currency) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(currency)
                        }
                    }
                }
            }
            .navigationTitle("Select Currencies")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: selectAllCurrencies) {
                            Image(systemName: "checkmark.circle")
                        }
                        .help("Select All")

                        Button(action: clearAllCurrencies) {
                            Image(systemName: "xmark.circle")
                        }
                        .help("Clear All")

                        Button(action: {
                            sortOrder.toggle()
                        }) {
                            Image(systemName: sortOrder ? "arrow.up" : "arrow.down")
                        }

                        Button(action: {
                            selectedFilter = selectedFilter.next
                        }) {
                            Image(systemName: selectedFilter.icon)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDone()
                    }
                }
            }
            .onAppear {
                viewModel.fetchStatistics()
            }
        }
    }

    private func toggleSelection(_ currency: String) {
        var updatedSelection = viewModel.selectedCurrencies

        if updatedSelection.contains(currency) {
            updatedSelection.remove(currency)
        } else {
            updatedSelection.insert(currency)
        }

        viewModel.updateSelectedCurrencies(updatedSelection)
    }

    private func selectAllCurrencies() {
        viewModel.updateSelectedCurrencies(Set(viewModel.filteredAvailableCurrencies))
    }

    private func clearAllCurrencies() {
        viewModel.updateSelectedCurrencies([])
    }
}


