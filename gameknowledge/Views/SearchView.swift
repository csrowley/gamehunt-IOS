import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var viewModel = ViewModel()
    @Environment(\.modelContext) var modelContext
    @AppStorage("firstLaunch") private var isFirstLaunch: Bool = true
    @Query var searchNames: [SearchTerms]
    
    @State private var searchText = ""
    @Binding var selectedText: String

    @State private var items: [String] = []
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(searchText.isEmpty ? items : items.filter { $0.contains(searchText) }, id: \.self) { item in
                        Button(action: {
                            selectedText = item
                        }) {
                            Text(item)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
        }
        .onAppear {
            if isFirstLaunch {
                if let populateNames = viewModel.loadNames() {
                    items = populateNames
                    
                    let insertNames = SearchTerms(names: populateNames)
                    modelContext.insert(insertNames)
                }
            } else {
                // Update items from searchNames if available
                if let names = searchNames.first?.names {
                    items = names
                }
            }
        }
    }
}

#Preview {
    SearchView(selectedText: .constant(""))
}
