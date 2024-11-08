//
//  InfiniteViewModel.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/6/24.
//

import Foundation

extension InfiniteView{
    
    @Observable
    class ViewModel{
        var correctGuess = "Apple" //will change to DB call?
        var searchText = ""
        var numLives = 5
        var unqiueGuesses: Set<String> = []
        var userGuessed: [String] = []
        var submitFlag = false
        var toggleSheetView = false
        var isWinner = false
        var todaysCoverURL = "https://images.igdb.com/igdb/image/upload/t_cover_big/co85h5.jpg"
        var score: Int = 0
        
        let gameHelper = GuessingHelpers()
    }
    
    
}
