import SwiftUI

struct GuessingView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)
    
    @State private var viewModel = ViewModel()
    @State private var test = "hi"
    @State private var showGameOverAlert = false // State for showing game over alert
    @AppStorage("blurCount") private var blurCount: Int = 12
    init() {
        UISearchBar.appearance().overrideUserInterfaceStyle = .dark
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
                    AsyncImage(url: URL(string: viewModel.todaysCoverURL)) { image in
                        image
                            .resizable()
                            .frame(width: 250, height: 250)
                            .blur(radius: CGFloat(blurCount))
                    } placeholder: {
                        ProgressView()
                    }
                    
                    HStack {
                        ForEach(0..<viewModel.numLives, id: \.self) { idx in
                            Image(.heart)
                        }
                    }
                    .padding(.bottom, 5)
                    
                    VStack {
                        HStack {
                            TextField("Click 'Search All Games' To Start", text: $viewModel.searchText)
                                .disabled(true)
                            
                            Button {
                                viewModel.submitFlag.toggle()
                                
                                if !viewModel.isWinner && !viewModel.unqiueGuesses.contains(viewModel.searchText) && !viewModel.searchText.isEmpty {
                                    if viewModel.searchText == viewModel.correctGuess {
                                        // Show winner screen
                                        viewModel.isWinner.toggle()
                                    } else {
                                        // Decrease lives and check for game over
                                        if viewModel.numLives - 1 < 0 {
                                            showGameOverAlert = true // Set alert to show
                                        } else {
                                            viewModel.numLives -= 1
                                            
                                            if viewModel.numLives == 0{
                                                showGameOverAlert = true
                                                viewModel.unqiueGuesses.insert(viewModel.searchText)
                                                viewModel.userGuessed.append(viewModel.searchText)
                                            }
                                        }
                                        
                                        blurCount -= 2
                                    }
                                    
                                    if viewModel.numLives > 0{
                                        viewModel.unqiueGuesses.insert(viewModel.searchText)
                                        viewModel.userGuessed.append(viewModel.searchText)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.right.square.fill")
                                    .foregroundStyle(Color.green)
                                    .font(.system(size: 30))
                            }
                        }
                        .padding()
                        .foregroundColor(Color.black)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        Button {
                            viewModel.toggleSheetView.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search All Games")
                                    .font(Font.custom("Jersey10-Regular", size: 25))
                            }
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                    .sheet(isPresented: $viewModel.toggleSheetView) {
                        SearchView(selectedText: $viewModel.searchText)
                            .presentationDetents([.height(300), .medium, .large])
                            .presentationDragIndicator(.automatic)
                    }
                    
                    List {
                        ForEach(viewModel.userGuessed, id: \.self) { name in
                            HStack {
                                Text(name)
                                    .font(Font.custom("Jersey10-Regular", size: 25))
                                    .foregroundColor(.white)
                                Spacer()
                                if name == viewModel.correctGuess {
                                    Text("Winner")
                                        .font(Font.custom("Jersey10-Regular", size: 25))
                                        .foregroundColor(.green)
                                } else {
                                    Text("Wrong saga")
                                        .font(Font.custom("Jersey10-Regular", size: 25))
                                        .foregroundColor(.red)
                                }
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
        // Alert when the game is over
        .alert(isPresented: $showGameOverAlert) {
            Alert(title: Text("Game Over"),
                  message: Text("You've run out of lives. Answer: \(viewModel.correctGuess)"),
                  dismissButton: .default(Text("OK")) {
                      // Reset or any other action when the alert is dismissed
                  })
        }
    }
}

#Preview {
    GuessingView()
}
