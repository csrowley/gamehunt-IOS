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
                
        let supabase = SupabaseClient(
          supabaseURL: URL(string: "https://eholmptawlihmlaxkmzx.supabase.co")!,
          supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVob2xtcHRhd2xpaG1sYXhrbXp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc4NDY0MDYsImV4cCI6MjA0MzQyMjQwNn0.fwUm8KyS4IVWhBlnFWBPKd37kCEtqLXlZZCBe8lRM6M"
          // public key (read - only)
        )
        
        
//        func getTodaysGameInfo() -> GameInfo{
//            
//        }
        
        struct GameInfo: Codable{
            let name: String
            let id: Int
            let franchise: Int?
            let release_date: String
            
        }
        
        
        struct coverURL: Codable {
            let cover_url: String
        }
        
        
        // dont use coverid from games table just use id
        func getCoverLink(_ coverID: Int) async throws -> String{
            let idToURL: [coverURL] = try await supabase
                .from("Covers")
                .select("cover_url")
                .eq("cover_id", value: coverID)
                .limit(1)
                .execute()
                .value
            
            guard let resURL = idToURL.first?.cover_url else {
                print(idToURL)
                print("Error with fetching URL")
                return ""
            }
            
            return resURL
            

        }
        
        //currently will get a random game id
        // could retrieve its foreign key equivalent with id
        
        // retrieve all ids from csv, and store in userdefaults and get random one to search
        //
        
        func getGameInfo(_ id: Int) async throws -> GameInfo? {
            let randomGame: [GameInfo] = try await supabase
                .from("Games")
                .select()
                .eq("id", value: id)
                .limit(1)
                .execute()
                .value
            
            guard let gameInfo = randomGame.first else {
                print("Error with fetching game info")
                return nil
            }
            return gameInfo
        }
        
        func importAllIds() -> [Int]? {
            guard let pathName = Bundle.main.url(forResource: "ids", withExtension: "json") else{
                print("Path Not Found for 'ids.json'")
                return nil
            }
            
            do{
                let data = try Data(contentsOf: pathName)
                let ids = try JSONDecoder().decode([Int].self, from: data)
                return ids
            } catch {
                print("Error returning ids")
                return nil
            }
        }
        
        
        func loadNames() -> [String]? {
            guard let pathName = Bundle.main.url(forResource: "names", withExtension: "json") else{
                print("Path Not Found for 'names.json'")
                return nil
            }
            
            do{
                let data = try Data(contentsOf: pathName)
                let names = try JSONDecoder().decode([String].self, from: data)
                return names
            } catch {
                print("Error returning names")
                return nil
            }
            
        }
        
        
        func getRandomID(_ allIds: [Int]) -> Int?{
            if let randomID = allIds.randomElement(){
                return randomID
            }
            else{
                print("Error returning random ID")
                return nil
            }
        }
        
        
        func checkForRefresh(_ lastLoginDateString: String) -> Bool {
            let currentDate = Date()
            
            // Check for an empty string
            guard !lastLoginDateString.isEmpty else {
                print("Last login date string is empty.")
                return true // Treat as a refresh needed
            }
            
            // Create a DateFormatter to parse the input string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust the format according to your date string
            
            // Convert the string to Date
            guard let lastLoginDate = dateFormatter.date(from: lastLoginDateString) else {
                print("Failed to convert string to date: \(lastLoginDateString)")
                return true // Treat as a refresh needed
            }
            
            // Check if the last login date is not the same as the current date
            if !Calendar.current.isDate(lastLoginDate, inSameDayAs: currentDate) {
                return true // A new day has started
            }
            
            return false // Same day
        }


        
        
        
    }
}
