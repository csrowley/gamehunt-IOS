//
//  GuessingHelpers.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/6/24.
//

/// with search and id arrays in swift data, i can possibly create 1 array? with formaat of [(id, name)] when looping through list of search data, when user clicks a search term we can retrieve the franchise with the id and give data in the results

import Foundation
import Supabase

import Foundation
import Supabase

class GuessingHelpers {
    
    struct GameInfo: Codable {
        let name: String
        let id: Int
        let franchise: Int?
        let release_date: String
    }

    struct CoverURL: Codable {
        let cover_url: String
    }

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
