//
//  GuessingViewModel.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/1/24.
//

import Foundation
import Supabase


extension GuessingView{

    @Observable
    class ViewModel{
        var correctGuess = "Apple" //will change to DB call?
        var searchText = ""
        var searchID: Int64 = 0
        var numLives = 5
        var unqiueGuesses: Set<Int64> = []
        var userGuessed: [GameGuess] = []
        var submitFlag = false
        var toggleSheetView = false
        var isWinner = false
        var todaysCoverURL = "https://images.igdb.com/igdb/image/upload/t_cover_big/co85h5.jpg"
        
        let gameHelper = GuessingHelpers()
        
        
        
    }
    
    struct GameGuess: Codable, Identifiable{
        let name: String
        let id: Int64
        let sameFranchise: Bool
    }
}
