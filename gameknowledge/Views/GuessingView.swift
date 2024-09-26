import SwiftUI

struct GuessingView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)
    @State private var searchText = ""
    @State private var numLives = 5
    @State private var testNames = ["Warhammer 40k", "Call of Duty: Black Ops 6", "Destiny 2", "2077 CyberPunk", "The Witcher 3: Wild Hunt"]
    @State private var userGuessed: [String] = ["Warhammer 40k", "Call of Duty: Black Ops 6", "Destiny 2", "2077 CyberPunk", "The Witcher 3: Wild Hunt"]
    
    init() {
        UISearchBar.appearance().overrideUserInterfaceStyle = .dark
    }
    
    var filteredNames: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return testNames.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        ZStack {
            Color(darkGrey)
                .ignoresSafeArea()
            
            VStack {
                Text("Daily Guess")
                    .font(Font.custom("Jersey10-Regular", size: 50))
                    .foregroundStyle(.white)
                    .padding(.bottom, 25)
                
                VStack {
                    Image(._400K)
                        .resizable()
                        .frame(width: 250, height: 250)
                        .blur(radius: 0)
                    HStack{
                        ForEach(0..<numLives, id: \.self){ idx in
                            Image(.heart)
                                
                        }
                    }
                    .padding(.bottom, 5)
                    SearchBar(text: $searchText)
                    
                    
                    
                    List{
                        ForEach(userGuessed, id: \.self){ name in
                            HStack {
                                Text(name)
                                    .font(Font.custom("Jersey10-Regular", size: 25))

                                    .foregroundColor(.white)
                                Spacer()
                                Text("Wrong saga")
                                    .font(Font.custom("Jersey10-Regular", size: 25))
                                    .foregroundColor(.red)
                            }
                        }
                        .listRowBackground(Color(darkGrey))
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                }
                Spacer()
            }
        }
    }
}


struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for a game", text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

#Preview {
    GuessingView()
}
