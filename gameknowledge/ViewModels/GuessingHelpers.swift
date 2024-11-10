//
//  GuessingHelpers.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/6/24.
//

import Foundation
import Supabase

import Foundation
import Supabase

class GuessingHelpers {
    // Supabase client for database interactions
//    private let supabase: SupabaseClient
//
//    init() {
//        supabase = SupabaseClient(
//            supabaseURL: URL(string: "")!,
//            supabaseKey: "" // public key (read-only)
//        )
//    }

    struct GameInfo: Codable {
        let name: String
        let id: Int
        let franchise: Int?
        let release_date: String
    }

    struct CoverURL: Codable {
        let cover_url: String
    }

    // Fetch cover URL based on cover ID
//    func getCoverLink(_ coverID: Int) async throws -> String {
//        let idToURL: [CoverURL] = try await supabase
//            .from("Covers")
//            .select("cover_url")
//            .eq("cover_id", value: coverID)
//            .limit(1)
//            .execute()
//            .value
//
//        guard let resURL = idToURL.first?.cover_url else {
//            print("Error with fetching URL")
//            return ""
//        }
//        return resURL
//    }
//
//    // Fetch game info based on game ID
//    func getGameInfo(_ id: Int) async throws -> GameInfo? {
//        let randomGame: [GameInfo] = try await supabase
//            .from("Games")
//            .select()
//            .eq("id", value: id)
//            .limit(1)
//            .execute()
//            .value
//
//        guard let gameInfo = randomGame.first else {
//            print("Error with fetching game info")
//            return nil
//        }
//        return gameInfo
//    }

    // Load game IDs from JSON file
    func importAllIds() -> [Int]? {
        guard let pathName = Bundle.main.url(forResource: "ids", withExtension: "json") else {
            print("Path Not Found for 'ids.json'")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: pathName)
            let ids = try JSONDecoder().decode([Int].self, from: data)
            return ids
        } catch {
            print("Error returning ids")
            return nil
        }
    }

    // Load game names from JSON file
    func loadNames() -> [String]? {
        guard let pathName = Bundle.main.url(forResource: "names", withExtension: "json") else {
            print("Path Not Found for 'names.json'")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: pathName)
            let names = try JSONDecoder().decode([String].self, from: data)
            return names.sorted()
        } catch {
            print("Error returning names")
            return nil
        }
    }

    // Generate a random ID from a list of IDs
    func getRandomID(_ allIds: [Int]) -> Int? {
        if let randomID = allIds.randomElement() {
            return randomID
        } else {
            print("Error returning random ID")
            return nil
        }
    }

    // Check if a refresh is needed based on the last login date
    func checkForRefresh(_ lastLoginDateString: String) -> Bool {
        let currentDate = Date()
        
        guard !lastLoginDateString.isEmpty else {
            return true // Treat as a refresh needed if the date string is empty
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let lastLoginDate = dateFormatter.date(from: lastLoginDateString) else {
            return true // Treat as a refresh needed if the date conversion fails
        }
        
        return !Calendar.current.isDate(lastLoginDate, inSameDayAs: currentDate)
    }
}
