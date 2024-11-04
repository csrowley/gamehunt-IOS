import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var viewModel = ViewModel()
    @Environment(\.modelContext) var modelContext
    @Query var searchNames: [SearchTerms]
    
    @State private var searchText = ""
    @Binding var selectedText: String
    @State private var items: [String] = []
    
    // Computed property for filtered names based on searchText
    private var filteredNames: [String] {
        searchText.isEmpty ? items : items.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // Use filteredNames here
                    ForEach(filteredNames, id: \.self) { item in
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
            // Update items from searchNames if available
            if let names = searchNames.first?.names {
                items = names
            }
            else{
                print("no names")
                print(searchNames)
            }
            
        }
    }
}

#Preview {
    SearchView(selectedText: .constant(""))
}
