import SwiftUI

// add saving for guesses, score, and game when user leaves game or disconnects screen and


struct GuessingView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)
    
    @State private var viewModel = ViewModel()
    @State private var test = "hi"
    
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
                            .blur(radius: 0) // 20?
                            
                                        
                        
                    } placeholder: {
                        ProgressView()
                    }
                    

                    HStack{
                        ForEach(0..<viewModel.numLives, id: \.self){ idx in
                            Image(.heart)
                                
                        }
                    }
                    .padding(.bottom, 5)
                    VStack{
                        HStack{
                            TextField("Click 'Search All Games' To Start", text: $viewModel.searchText)
                                .disabled(true)
                            
                            Button{
//                                Task{
//                                    do{
//                                        viewModel.todaysCoverURL = try await viewModel.getCoverLink(1)
//                                    }
//                                }
                                Task{
                                    do{
                                        test = try await viewModel.getGameInfo(1)?.name ?? ""
                                    }
                                }
                                viewModel.submitFlag.toggle()
                                if !viewModel.isWinner && !viewModel.unqiueGuesses.contains(viewModel.searchText) && !viewModel.searchText.isEmpty{
                                    if viewModel.searchText == viewModel.correctGuess{
                                        // show winner screeen etc
                                        viewModel.isWinner.toggle()
                                        
                                        // if winner, display a timer until 12AM for the next daily guess?
                                    }
                                    else{
                                        viewModel.numLives -= 1
                                    }
                                    
                                    
                                    viewModel.unqiueGuesses.insert(viewModel.searchText)
                                    viewModel.userGuessed.append(viewModel.searchText)
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
                        
                        Button{
                            viewModel.toggleSheetView.toggle()
 
                        } label: {
                            HStack{
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
                    .sheet(isPresented: $viewModel.toggleSheetView){
                        SearchView(selectedText: $viewModel.searchText)
                            .presentationDetents([.height(325), .medium, .large])
                            .presentationDragIndicator(.automatic)
                    }
                    
                    
                    
                    List{
                        ForEach(viewModel.userGuessed, id: \.self){ name in
                            HStack {
                                Text(name)
                                    .font(Font.custom("Jersey10-Regular", size: 25))

                                    .foregroundColor(.white)
                                Spacer()
                                if name == viewModel.correctGuess {
                                    Text("Winner")
                                        .font(Font.custom("Jersey10-Regular", size: 25))
                                        .foregroundColor(.green)
                                    // stop allowing guesses after this
                                    // if classic mode then put next game up and reset
                                }
                                else{
                                    // if wrong saga...
                                    Text("Wrong saga")
                                        .font(Font.custom("Jersey10-Regular", size: 25))
                                        .foregroundColor(.red)
                                    // if completely wrong ...
                                    //if correct saga ...
     
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
    }
}

#Preview {
    GuessingView()
}
