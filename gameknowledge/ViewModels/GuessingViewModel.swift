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
        var numLives = 5
        var unqiueGuesses: Set<String> = []
        var userGuessed: [String] = []
        var submitFlag = false
        var toggleSheetView = false
        var isWinner = false
        var todaysCoverURL = "https://images.igdb.com/igdb/image/upload/t_cover_big/co85h5.jpg"
        
        let gameHelper = GuessingHelpers()
        
        
        
    }
}
