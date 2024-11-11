import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var viewModel = ViewModel()
    @Environment(\.modelContext) var modelContext
    @Query var searchNames: [SearchTerms]
    
    @State private var searchText = ""
    @Binding var selectedText: String
    @Binding var selectedID: Int64
    @State private var items: [SearchData] = []
    @Environment(\.dismiss) var dismiss
    
    // Computed property for filtered names based on searchText
    private var filteredNames: [SearchData] {
        searchText.isEmpty ? items : items.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // Use filteredNames here
                    ForEach(filteredNames, id: \.self) { item in
                        Button(action: {
                            selectedText = item.name
                            dismiss()
                        }) {
                            Text(item.name)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
        }
        .onAppear {
            // Update items from searchNames if available
            if let searchData = searchNames.first?.data {
                items = searchData
            }
            else{
                print("no searchData")
                print(searchNames)
            }
            
        }
    }
}

#Preview {
    SearchView(selectedText: .constant(""), selectedID: .constant(0))
}
