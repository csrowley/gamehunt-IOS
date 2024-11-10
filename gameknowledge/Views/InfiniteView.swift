//
//  InfiniteView.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/6/24.
//

import SwiftUI
import SwiftData
///
///must reset game id  and info for every correct or game over guess (done?)
/// must reset  blur count for every correct or game over (done?)
/// increase score every win (done?)
/// get rid of game rest for every day, keep it persist (done?)
///
/// doesnt refresh a new game for first launch?
/// doesnt refresh a new game after a win?
///

struct InfiniteView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)
    
    @State private var viewModel = ViewModel()
    @State private var showGameOverAlert = false // State for showing game over alert
    @AppStorage("blurCountInfinite") private var blurCountInfinite: Int = 12
    
    @Environment(\.modelContext) var modelContext
    @Query var gameIds: [GameIds]
    
    @AppStorage("firstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("infiniteGuess") private var infiniteGuess: String = "Buckshot Roulette"
    
    @AppStorage("infiniteGuessID") private var infiniteGuessID: Int = 1
    @AppStorage("infiniteGuessCoverURL") private var infiniteGuessCoverURL: String = "https://images.igdb.com/igdb/image/upload/t_cover_big/co85h5.jpg"
    
    @AppStorage("infiniteGuessFranchise") private var infiniteGuessFranchise: String = "None"
    
    @AppStorage("infiniteLives") private var numLivesLeft: Int = 5
    @AppStorage("userGuessesInfinite") private var infiniteUserGuess: Data?
    @AppStorage("isWinnerInfinite") private var isWinnerInfinite: Bool = false
    
    @AppStorage("infiniteScore") private var infiniteScore: Int = 0
    @State private var prevAnswer = "Buckshot Roulette"
    
    init() {
        UISearchBar.appearance().overrideUserInterfaceStyle = .dark
    }
    
    var body: some View {
        ZStack {
            Color(darkGrey)
                .ignoresSafeArea()
            
            VStack {
                Text("Infinite Mode")
                    .font(Font.custom("Jersey10-Regular", size: 50))
                    .foregroundStyle(.white)
//                    .padding(.bottom)
                
                HStack{
                    Text("Score:")
                        .font(Font.custom("Jersey10-Regular", size: 30))
                        .foregroundStyle(.white)
                    Text(String(infiniteScore))
                        .font(Font.custom("Jersey10-Regular", size: 30))
                        .foregroundStyle(.orange)
                }
                VStack {
                    AsyncImage(url: URL(string: infiniteGuessCoverURL)) { image in
                        image
                            .resizable()
                            .frame(width: 250, height: 250)
                            .blur(radius: CGFloat(blurCountInfinite))
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
                                        
                    if isWinnerInfinite {
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
                                prevAnswer = infiniteGuess
                                if numLivesLeft > 0 && !viewModel.unqiueGuesses.contains(viewModel.searchText) && !viewModel.searchText.isEmpty {
                                    if viewModel.searchText == infiniteGuess {
                                        // Show winner screen and reset for a new game
                                        infiniteScore += (numLivesLeft * 2)
                                        viewModel.isWinner = true
                                        numLivesLeft = 5
                                        blurCountInfinite = 12 // Reset blur count
                                        viewModel.userGuessed.removeAll()
                                        viewModel.unqiueGuesses.removeAll()
                                        saveGuesses(true)

                                        Task {
                                            if let allIds = gameIds.first?.ids {
                                                await fetchNewGuess(allIds: allIds)
                                            } else {
                                                print("Error! No game IDs available.")
                                            }
                                            
                                            // Reset states for the next round
                                            viewModel.searchText = "" // Clear search text
                                            viewModel.submitFlag = false // Reset submit flag
                                            isWinnerInfinite = false // Reset winner flag
                                        }

                                    } else {
                                        // Decrease lives and check for game over
                                        if numLivesLeft > 1 {
                                            viewModel.numLives -= 1
                                            numLivesLeft -= 1
                                            viewModel.unqiueGuesses.insert(viewModel.searchText)
                                            viewModel.userGuessed.append(viewModel.searchText)
                                            saveGuesses(false)
                                            blurCountInfinite = max(2, blurCountInfinite - 2)
                                        } else {
                                            showGameOverAlert = true // Trigger the game-over alert
                                            infiniteScore = 0
                                            
                                            
                                            numLivesLeft = 5
                                            blurCountInfinite = 12 // Reset blur count
                                            viewModel.userGuessed.removeAll()
                                            viewModel.unqiueGuesses.removeAll()
                                            saveGuesses(true)

                                            Task {
                                                if let allIds = gameIds.first?.ids {
                                                    await fetchNewGuess(allIds: allIds)
                                                } else {
                                                    print("Error! No game IDs available.")
                                                }
                                                
                                                // Reset states for the next round
                                                viewModel.searchText = "" // Clear search text
                                                viewModel.submitFlag = false // Reset submit flag
                                                isWinnerInfinite = false // Reset winner flag
                                            }
                                            
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
                            .presentationDetents([.height(200), .medium, .large])
                            .presentationDragIndicator(.automatic)
                    }
                    
                    List {
                        ForEach(viewModel.userGuessed, id: \.self) { name in
                            HStack {
                                Text(name)
                                    .font(Font.custom("Jersey10-Regular", size: 25))
                                    .foregroundColor(.white)
                                Spacer()
                                if name == infiniteGuess {
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
            
            if isFirstLaunch {
                
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
                    infiniteGuessID = currGuessID
                                        
//                    Task{
//                        let currGameInfo = try await viewModel.gameHelper.getGameInfo(currGuessID)
//                        let currGameCoverURL = try await viewModel.gameHelper.getCoverLink(currGuessID)
//                        
//                        infiniteGuessCoverURL = currGameCoverURL
//                        infiniteGuess = currGameInfo!.name
//                        
//                        print(currGameInfo!.name)
//                        print(currGameCoverURL)
//                        
//                    }
                    
                    Task{
                        await LocalDatabase.populateDatabase()
                        
                        let currGameInfo = try await LocalDatabase.shared.getGame(id: Int64(currGuessID))
                        let currGameCoverURL = try await LocalDatabase.shared.getCover(id: Int64(currGuessID))
                        
                        infiniteGuessCoverURL = currGameCoverURL?.cover_url ?? "none"
                        infiniteGuess = currGameInfo?.name ?? "none"
                        
                        print(infiniteGuess)
                        print(infiniteGuessCoverURL)
                        
                    }
                    
                    
                    
                    
                }
                
                isFirstLaunch = false
            }


        }
        // Alert when the game is over
        .alert(isPresented: $showGameOverAlert) {
            Alert(title: Text("Game Over"),
                  message: Text("You've run out of lives. Answer: \(prevAnswer)"),
                  dismissButton: .default(Text("OK")) {
                      // Actions to perform when the alert is dismissed (like resetting for a new game)
                  })
        }
    }
    
    private func saveGuesses(_ isNewLoad: Bool){
        if isNewLoad{
            infiniteUserGuess = Data()
        }
        else if let data = try? JSONEncoder().encode(viewModel.userGuessed){
            infiniteUserGuess = data
        }
    }
    
    private func loadGuesses(){
        if let data = infiniteUserGuess,
           let savedData = try? JSONDecoder().decode([String].self, from: data){
            viewModel.userGuessed = savedData
        }
    }
    
    
    @MainActor
    private func fetchNewGuess(allIds: [Int]) async {
        do {
            // Ensure `getRandomID` returns an optional, as only it requires optional binding
            if let currGuessID = viewModel.gameHelper.getRandomID(allIds) {
                // Since `getGameInfo` and `getCoverLink` return non-optional values, assign them directly
                let currGameInfo = try await LocalDatabase.shared.getGame(id: Int64(currGuessID))
                let currGameCoverURL = try await LocalDatabase.shared.getCover(id: Int64(currGuessID))
                
                // Assign values after async operations are complete
                infiniteGuessCoverURL = currGameCoverURL?.cover_url ?? ""
                infiniteGuess = currGameInfo?.name ?? "No Game Found"
                infiniteGuessID = currGuessID
            } else {
                print("Error: Unable to retrieve a random ID.")
            }
        } catch {
            print("Error fetching new guess: \(error)")
        }
    }




}

#Preview {
    InfiniteView()
}
