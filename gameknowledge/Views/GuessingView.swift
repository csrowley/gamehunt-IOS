import SwiftUI
import SwiftData

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
    @AppStorage("userGuessesDaily") private var dailyUserGuess: Data?
    @AppStorage("isWinner") private var isWinner: Bool = false
    @AppStorage("dailyStreak") private var dailyStreak: Int = 0
    
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
                
                HStack {
                    Text("Streak: ")
                        .font(Font.custom("Jersey10-Regular", size: 30))
                        .foregroundStyle(.white)
                    Text(String(dailyStreak))
                        .font(Font.custom("Jersey10-Regular", size: 30))
                        .foregroundStyle(.orange)
                }
                
                VStack {
                    AsyncImage(url: URL(string: dailyGuessCoverURL)) { image in
                        image
                            .resizable()
                            .frame(width: 250, height: 250)
                            .blur(radius: CGFloat(blurCount))
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    HStack {
                        if numLivesLeft > 0{
                            ForEach(0..<numLivesLeft, id: \.self) { idx in
                                Image(.heart)
                            }
                        }
                        else{
                            Text("Game Over")
                                .font(Font.custom("Jersey10-Regular", size: 30))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.bottom, 5)
                                        
                    if isWinner {
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
                                
                                if numLivesLeft > 0 && !isWinner && !viewModel.unqiueGuesses.contains(viewModel.searchText) && !viewModel.searchText.isEmpty {
                                    if viewModel.searchText == dailyGuess {
                                        // Show winner screen
                                        isWinner.toggle()
                                        blurCount = 0
                                        dailyStreak += 1
                                    } else {
                                        // Decrease lives and check for game over
                                        if numLivesLeft > 1 {
                                            viewModel.numLives -= 1
                                            numLivesLeft -= 1
                                            viewModel.unqiueGuesses.insert(viewModel.searchText)
                                            viewModel.userGuessed.append(viewModel.searchText)
                                            saveGuesses(false)
                                            blurCount = max(3, blurCount - 2)
                                        } else {
                                            dailyStreak = 0
                                            
                                            numLivesLeft = 0
                                            blurCount = 12
                                            showGameOverAlert = true // Trigger the game-over alert
                                        }
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
                                    Text("Wrong")
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
            loadGuesses()
            let todaysDate = Date()
            let formatter = DateFormatter()
            
            formatter.dateFormat = "yyyy-MM-dd"
            let lastLoginString = formatter.string(from: todaysDate)
            
            if isFirstLaunch {

                lastLoginDate = lastLoginString
                
                if let populateNames = viewModel.gameHelper.loadNames() {
                    let insertNames = SearchTerms(names: populateNames)
                    modelContext.insert(insertNames)
                    do{
                        try modelContext.save()
                    } catch {
                        print("Error Saving names")
                    }
                }
                
                if let populateIds = viewModel.gameHelper.importAllIds(){
                    let insertIDS = GameIds(ids: populateIds)
                    modelContext.insert(insertIDS)
                    do{
                        try modelContext.save()
                    } catch {
                        print("Error Saving ids")
                    }
                    let currGuessID = viewModel.gameHelper.getRandomID(insertIDS.ids)!
                    dailyGuessID = currGuessID
                                        
                    Task{
                        await LocalDatabase.populateDatabase()
                        let currGameInfo = try await LocalDatabase.shared.getGame(id: Int64(currGuessID))
                        let currGameCoverURL = try await LocalDatabase.shared.getCover(id: Int64(currGuessID))
                        
                        dailyGuessCoverURL = currGameCoverURL?.cover_url ?? ""
                        dailyGuess = currGameInfo?.name ?? ""
                        
                        print(currGameInfo?.name ?? "no name")
                        print(currGameCoverURL?.cover_url ?? "no url")
                        
                    }
                    
                    
                }
                
                isFirstLaunch = false
            }
            else if viewModel.gameHelper.checkForRefresh(lastLoginDate){
                saveGuesses(true)
                isWinner = false
                viewModel.userGuessed.removeAll()
                viewModel.unqiueGuesses.removeAll()
                numLivesLeft = 5
                blurCount = 12
                Task{
                    if let allIds = gameIds.first?.ids{
                        let currGuessID = viewModel.gameHelper.getRandomID(allIds)
                        let currGameInfo = try await LocalDatabase.shared.getGame(id: Int64(currGuessID!))
                        let currGameCoverURL = try await LocalDatabase.shared.getCover(id: Int64(currGuessID!))
                        
                        dailyGuessCoverURL = currGameCoverURL?.cover_url ?? ""
                        dailyGuess = currGameInfo?.name ?? ""
                        dailyGuessID = currGuessID!
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
                      // Actions to perform when the alert is dismissed (like resetting for a new game)
                  })
        }
    }
    
    private func saveGuesses(_ isNewLoad: Bool){
        if isNewLoad{
            dailyUserGuess = Data()
        }
        else if let data = try? JSONEncoder().encode(viewModel.userGuessed){
            dailyUserGuess = data
        }
    }
    
    private func loadGuesses(){
        if let data = dailyUserGuess,
           let savedData = try? JSONDecoder().decode([String].self, from: data){
            viewModel.userGuessed = savedData
        }
    }
}

#Preview {
    GuessingView()
}
