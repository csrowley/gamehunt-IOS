import SwiftUI
import SwiftData
/// import all ids to get a random id for picking games (done)
/// create persistance for each modes guesses and blur effect
/// implement id picking and grab coverart url, and set the correct guess when picked (done)
/// implemet when won, if daily new guess wont show until 12am, if infinite new guess shows when clicking continue or clicking off the alert
/// implement a score on infinite mode
///



struct GuessingView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)
    
    @State private var viewModel = ViewModel()
    @State private var test = "hi"
    @State private var showGameOverAlert = false // State for showing game over alert
    @AppStorage("blurCount") private var blurCount: Int = 12
    
    @Environment(\.modelContext) var modelContext
    @Query var gameIds: [GameIds]
    
    @AppStorage("firstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("dailyGuess") private var dailyGuess: String = "Buckshot Roulette"
    @AppStorage("dailyGuessID") private var dailyGuessID: Int = 1
    @AppStorage("dailyGuessCoverURL") private var dailyGuessCoverURL: String = "https://images.igdb.com/igdb/image/upload/t_cover_big/co85h5.jpg"
    @AppStorage("dailyGuessFranchise") private var dailyGuessFranchise: String = "None"
    @AppStorage("lastLoginDate") private var lastLoginDate: String = ""
    
    @AppStorage("dailyLives") private var numLivesLeft: Int = 5
    
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
                    AsyncImage(url: URL(string: dailyGuessCoverURL)) { image in
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
                                        
                    if showGameOverAlert {
                        Text("Game Over")
                            .font(Font.custom("Jersey10-Regular", size: 30))
                            .foregroundColor(.red)
                    } else if viewModel.isWinner {
                        Text("Winner")
                            .font(Font.custom("Jersey10-Regular", size: 30))
                            .foregroundColor(.green)
                    }
                    
                    VStack {
                        HStack {
                            TextField("Click 'Search All Games' To Start", text: $viewModel.searchText)
                                .disabled(true)
                            
                            Button {
                                viewModel.submitFlag.toggle()
                                
                                if !viewModel.isWinner && !viewModel.unqiueGuesses.contains(viewModel.searchText) && !viewModel.searchText.isEmpty {
                                    if viewModel.searchText == dailyGuess {
                                        // Show winner screen
                                        viewModel.isWinner.toggle()
                                        blurCount = 0
                                    } else {
                                        // Decrease lives and check for game over
                                        if viewModel.numLives - 1 < 0 {
                                            showGameOverAlert = true // Set alert to show
                                            blurCount = 12
                                        } else {
                                            viewModel.numLives -= 1
                                            numLivesLeft -= 1
                                            
                                            if viewModel.numLives == 0{
                                                showGameOverAlert = true
                                                blurCount = 12
                                                viewModel.unqiueGuesses.insert(viewModel.searchText)
                                                viewModel.userGuessed.append(viewModel.searchText)
                                            }
                                        }
                                        
                                        blurCount = max(2, blurCount - 2)
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
                                if name == dailyGuess {
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
        .onAppear {
            let todaysDate = Date()
            let formatter = DateFormatter()
            
            formatter.dateFormat = "yyyy-MM-dd"
            let lastLoginString = formatter.string(from: todaysDate)
            
            if isFirstLaunch {

                lastLoginDate = lastLoginString
                print(lastLoginDate)
                
                if let populateNames = viewModel.loadNames() {
                    let insertNames = SearchTerms(names: populateNames)
                    modelContext.insert(insertNames)
                    do{
                        try modelContext.save()
                    } catch {
                        print("Error Saving names")
                    }
                }
                
                if let populateIds = viewModel.importAllIds(){
                    let insertIDS = GameIds(ids: populateIds)
                    modelContext.insert(insertIDS)
                    do{
                        try modelContext.save()
                    } catch {
                        print("Error Saving ids")
                    }
                    let currGuessID = viewModel.getRandomID(insertIDS.ids)!
                    dailyGuessID = currGuessID
                                        
                    Task{
                        let currGameInfo = try await viewModel.getGameInfo(currGuessID)
                        let currGameCoverURL = try await viewModel.getCoverLink(currGuessID)
                        
                        dailyGuessCoverURL = currGameCoverURL
                        dailyGuess = currGameInfo!.name
                        
                        print(currGameInfo!.name)
                        print(currGameCoverURL)
                        
                    }
                    
                    
                }
                
                isFirstLaunch = false
            }
            else if viewModel.checkForRefresh(lastLoginDate){
                
                Task{
                    if let allIds = gameIds.first?.ids{
                        let currGuessID = viewModel.getRandomID(allIds)
                        let currGameInfo = try await viewModel.getGameInfo(currGuessID!)
                        let currGameCoverURL = try await viewModel.getCoverLink(currGuessID!)
                        
                        dailyGuessCoverURL = currGameCoverURL
                        dailyGuess = currGameInfo!.name
                        dailyGuessID = currGuessID!
                        
//                        
//                        print("First Guess \(dailyGuess)")
//                        print("First Guess \(currGuessID)")
//                        print("First Guess \(dailyGuessCoverURL)")

                    }
                    
                    lastLoginDate = lastLoginString
                }
            }
        }
        // Alert when the game is over
        .alert(isPresented: $showGameOverAlert) {
            Alert(title: Text("Game Over"),
                  message: Text("You've run out of lives. Answer: \(dailyGuess)"),
                  dismissButton: .default(Text("OK")) {
                      // Reset or any other action when the alert is dismissed
                  })
        }
    }
}

#Preview {
    GuessingView()
}
