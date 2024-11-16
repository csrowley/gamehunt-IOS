//
//  InfiniteView.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/6/24.
//

import SwiftUI
import SwiftData
import ConfettiSwiftUI

struct InfiniteView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)
    
    @State private var viewModel = ViewModel()
    @State private var showGameOverAlert = false // State for showing game over alert
    @State private var showHintAlert = false
    @State private var infiniteGuessInfo: Game? = nil
    @AppStorage("blurCountInfinite") private var blurCountInfinite: Double = 12 //revert
    
    @Environment(\.modelContext) var modelContext
    @Query var searchData: [SearchTerms]
    
    @AppStorage("firstLaunch") private var isFirstLaunch: Bool = true
    
    @AppStorage("infiniteGuess") private var infiniteGuess: String = "Buckshot Roulette"
    @AppStorage("infiniteGuessID") private var infiniteGuessID: Int = 1
    @AppStorage("infiniteGuessCoverURL") private var infiniteGuessCoverURL: String = "https://images.igdb.com/igdb/image/upload/t_cover_big/co85h5.jpg"
    @AppStorage("infiniteGuessFranchise") private var infiniteGuessFranchise: String = ""
    @AppStorage("infiniteLives") private var numLivesLeft: Int = 5
    @AppStorage("userGuessesInfinite") private var infiniteUserGuess: Data?
    @AppStorage("isWinnerInfinite") private var isWinnerInfinite: Bool = false
    
    @AppStorage("infiniteScore") private var infiniteScore: Int = 0
    @AppStorage("isHintUsed") private var isHintUsed: Bool = false
    @AppStorage("showHintText") private var showHintText: Bool = false
    @AppStorage("hintText") private var hintText: String = ""
    
    @State private var sameFranchiseGuess: Bool = false
    @State private var displayGames: Game?
    @State private var showConfetti: Int = 0
    @State private var showSkipAlert: Bool = false
    
    
    
    @AppStorage("prevAnswer") private var prevAnswer = "Buckshot Roulette"
    
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
                    
                    if showHintText && !isWinnerInfinite && numLivesLeft > 0{
                            HStack {
                                Text("Hint:")
                                    .font(Font.custom("Jersey10-Regular", size: 30))
                                    .foregroundColor(.white)
                                Text("\(infiniteGuessFranchise)") // insert franchise hint
                                    .font(Font.custom("Jersey10-Regular", size: 30))
                                    .foregroundColor(.orange)
                                
                            }
                    }
                                        
                    else if isWinnerInfinite {
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
                                
                                if numLivesLeft > 0 && !viewModel.unqiueGuesses.contains(viewModel.searchID) && !viewModel.searchText.isEmpty {
                                    if viewModel.searchText == infiniteGuess {
                                        // Show winner screen and reset for a new game
                                        infiniteScore += (numLivesLeft * 2)
                                        viewModel.isWinner = true
                                        numLivesLeft = 5
                                        blurCountInfinite = 12 // Reset blur count
                                        viewModel.userGuessed.removeAll()
                                        viewModel.unqiueGuesses.removeAll()
                                        saveGuesses(true)
                                        showConfetti += 1
                                        
                                        Task {
                                            if let data = searchData.first {
                                                await fetchNewGuess(data)
                                            } else {
                                                print("Error! No game IDs available.")
                                            }
                                            
                                            // Reset states for the next round
                                            viewModel.searchText = "" // Clear search text
                                            viewModel.submitFlag = false // Reset submit flag
                                            isWinnerInfinite = false // Reset winner flag
                                            showHintText = false
                                        }
                                        
                                    } else {
                                        // Decrease lives and check for game over
                                        
                                        if numLivesLeft > 1 {
                                            
                                            Task {
                                                let isSameFranchise = await checkFranchiseMatch()
                                                viewModel.numLives -= 1
                                                numLivesLeft -= 1
                                                viewModel.unqiueGuesses.insert(viewModel.searchID)
                                                print("Is Same Franchhise Guess: \(isSameFranchise)")
                                                
                                                viewModel.userGuessed.append(GameGuess(name: viewModel.searchText, id: viewModel.searchID, sameFranchise: isSameFranchise))
                                                
                                                
                                                saveGuesses(false)
                                                blurCountInfinite = max(3, blurCountInfinite - 2) //revert
                                            }
                                        } else {
                                            showGameOverAlert = true // Trigger the game-over alert
                                            infiniteScore = 0
                                            
                                            
                                            numLivesLeft = 5
                                            blurCountInfinite = 12 // Reset blur count
                                            viewModel.userGuessed.removeAll()
                                            viewModel.unqiueGuesses.removeAll()
                                            saveGuesses(true)
                                            
                                            isHintUsed = false
                                            showHintText = false
                                            
                                            
                                            Task {
                                                if let data = searchData.first {
                                                    await fetchNewGuess(data)
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
                        .padding(.bottom)
                        .confettiCannon(counter: $showConfetti, num:50, confettiSize: 10, rainHeight: 700)
                        
                        HStack(spacing: 12) {  // Added consistent spacing between buttons
                            Group {  // Group helps apply same modifiers to all buttons
                                Button {
                                    viewModel.toggleSheetView.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                        Text("Search")
                                            .font(Font.custom("Jersey10-Regular", size: 20))
                                    }
                                    .frame(maxWidth: .infinity)  // Makes button expand to fill available space
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundStyle(Color.white)
                                    .cornerRadius(10)
                                }
                                
                                Button {
                                    if !isHintUsed {
                                        showHintAlert.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Hint")
                                            .font(Font.custom("Jersey10-Regular", size: 20))
                                            .foregroundStyle(.white)
                                        Image(systemName: "questionmark.app.fill")
                                            .foregroundStyle(.orange)
                                            .font(.system(size: 25))
                                            .symbolRenderingMode(.multicolor)
                                    }
                                    .frame(maxWidth: .infinity)  // Makes button expand to fill available space
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                }
                                
                                Button {
                                    showSkipAlert.toggle()
                                } label: {
                                    HStack {
                                        Text("Skip")
                                            .font(Font.custom("Jersey10-Regular", size: 20))
                                            .foregroundStyle(.white)
                                        Image(systemName: "arrow.forward")
                                            .font(.system(size: 15))
                                    }
                                    .frame(maxWidth: .infinity)  // Makes button expand to fill available space
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)  // Made consistent with other buttons
                                    .foregroundStyle(.white)
                                }
                            }
                        }
                        .padding(.horizontal)  // Moved padding to the HStack level
                        
                        // Rest of the code remains the same
                        .alert("Hint", isPresented: $showHintAlert) {
                            Button("Yes") {
                                isHintUsed.toggle()
                                showHintText.toggle()
                            }
                            Button("No", role: .cancel) {}
                        } message: {
                            Text("Use one time hint? Only one use per run.")
                        }
                        .alert("Skip?", isPresented: $showSkipAlert) {
                            Button("Yes") {
                                prevAnswer = infiniteGuess
                                showGameOverAlert = true // Trigger the game-over alert
                                infiniteScore = 0
                                numLivesLeft = 5
                                blurCountInfinite = 12 // Reset blur count
                                viewModel.userGuessed.removeAll()
                                viewModel.unqiueGuesses.removeAll()
                                saveGuesses(true)
                                
                                isHintUsed = false
                                showHintText = false
                                
                                Task {
                                    if let data = searchData.first {
                                        await fetchNewGuess(data)
                                    } else {
                                        print("Error! No game IDs available.")
                                    }
                                    
                                    // Reset states for the next round
                                    viewModel.searchText = "" // Clear search text
                                    viewModel.submitFlag = false // Reset submit flag
                                    isWinnerInfinite = false // Reset winner flag
                                }
                            }
                            Button("No", role: .cancel) {}
                        } message: {
                            Text("Skipping will reset your score!")
                        }
                        .sheet(isPresented: $viewModel.toggleSheetView) {
                            SearchView(selectedText: $viewModel.searchText, selectedID: $viewModel.searchID)
                                .presentationDetents([.height(200), .medium, .large])
                                .presentationDragIndicator(.automatic)
                        }
                        
                    }
                    
                    List {
                        ForEach(viewModel.userGuessed) { game in
//                            let retrieveName = try await LocalDatabase.shared.getGame(id: id)
                            HStack {
                                Text(game.name)
                                    .font(Font.custom("Jersey10-Regular", size: 25))
                                    .foregroundColor(.white)
                                Spacer()
                                if game.name == infiniteGuess {
                                    Text("Winner")
                                        .font(Font.custom("Jersey10-Regular", size: 25))
                                        .foregroundColor(.green)
                                } else {
                                    if game.sameFranchise {
                                        Text("Same Franchise")
                                            .font(Font.custom("Jersey10-Regular", size: 25))
                                            .foregroundColor(.yellow)
                                    }
                                    else {
                                        Text("Wrong")
                                            .font(Font.custom("Jersey10-Regular", size: 25))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .listRowBackground(Color(darkGrey))
                        }
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
                
                if let populateTerms = viewModel.gameHelper.loadNamesAndIds() {
                    let insertNames = SearchTerms(data: populateTerms)
                    modelContext.insert(insertNames)
                    do{
                        try modelContext.save()
                    } catch {
                        print("Error Saving names")
                    }
                    
                    
                    Task{
                        let currGuessID = viewModel.gameHelper.getRandomID(insertNames)

                        await LocalDatabase.populateDatabase()
                        
                        let currGameInfo = try await LocalDatabase.shared.getGame(id: Int64(currGuessID!))
                        let currGameCoverURL = try await LocalDatabase.shared.getCover(id: Int64(currGuessID!))
                        
                        if let franchiseID = Int64(currGameInfo?.franchise ?? ""){
                            let franchise = try await LocalDatabase.shared.getFranchise(id: Int64(franchiseID))
                            infiniteGuessFranchise = franchise?.name ?? ""
                            print(infiniteGuessFranchise)
                        }
                        else{
                            infiniteGuessFranchise = "No Franchise"
                        }
                        
                        infiniteGuessCoverURL = currGameCoverURL?.cover_url ?? "none"
                        infiniteGuess = currGameInfo?.name ?? "none"
                        prevAnswer = infiniteGuess
                        
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
    
    private func saveGuesses(_ isNewLoad: Bool) {
        if isNewLoad {
            infiniteUserGuess = Data()
        } else {
            // Encode the array of GameGuess structs directly
            if let data = try? JSONEncoder().encode(viewModel.userGuessed) {
                infiniteUserGuess = data
            }
        }
    }

    private func loadGuesses() {
        if let data = infiniteUserGuess,
           let savedData = try? JSONDecoder().decode([GameGuess].self, from: data) {
            // Decode directly to array of GameGuess
            viewModel.userGuessed = savedData
        }
    }
    
    
    @MainActor
    private func fetchNewGuess(_ termData: SearchTerms) async {
        do {
            // Ensure `getRandomID` returns an optional, as only it requires optional binding
            if let currGuessID = viewModel.gameHelper.getRandomID(termData) {
                // Since `getGameInfo` and `getCoverLink` return non-optional values, assign them directly
                let currGameInfo = try await LocalDatabase.shared.getGame(id: Int64(currGuessID))
                let currGameCoverURL = try await LocalDatabase.shared.getCover(id: Int64(currGuessID))
                
                if let franchiseID = Int64(currGameInfo?.franchise ?? ""){
                    let franchise = try await LocalDatabase.shared.getFranchise(id: Int64(franchiseID))
                    infiniteGuessFranchise = franchise?.name ?? ""
                    print(infiniteGuessFranchise)
                }
                
                else{
                    infiniteGuessFranchise = "No Franchise"
                    print("error obtaining franchise")
                }
                
                print(currGameInfo!.franchise!)
                
                // Assign values after async operations are complete
                infiniteGuessCoverURL = currGameCoverURL?.cover_url ?? ""
                infiniteGuess = currGameInfo?.name ?? "No Game Found"
                
                infiniteGuessID = Int(currGuessID)
                
            } else {
                print("Error: Unable to retrieve a random ID.")
            }
        } catch {
            print("Error fetching new guess: \(error)")
        }
    }


    private func checkFranchiseMatch() async -> Bool {
        let guessID = viewModel.searchID
        do {
            if let gameInfo = try await LocalDatabase.shared.getGame(id: guessID),
               let franchiseInt = Int64(gameInfo.franchise!),
               let guessFranchise = try await LocalDatabase.shared.getFranchise(id: franchiseInt) {

                // Perform MainActor updates within this async function
                await MainActor.run {
                    if (!infiniteGuessFranchise.isEmpty && !guessFranchise.name.isEmpty) && (infiniteGuessFranchise == guessFranchise.name) {
                        sameFranchiseGuess = true
                    } else {
                        sameFranchiseGuess = false
                    }
                    print("Infinite Guess Franchise: \(infiniteGuessFranchise)")
                    print("Your Guess Franchise: \(guessFranchise.name)")
                }
                return sameFranchiseGuess
            }
        } catch {
            print("Error with franchise comparison: \(error)")
        }
        return false
    }

}

#Preview {
    InfiniteView()
}
