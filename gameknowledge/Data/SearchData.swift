//
//  SearchData.swift
//  gameknowledge
//
//  Created by Chris Rowley on 10/7/24.
//
import SwiftData
import Foundation

extension SearchView{
    
    @Observable
    class ViewModel{
//        var allNames: [String] = []
//        
//        init(allNames: [String]) {
//            self.allNames = allNames
//        }
        
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
    }
    
    
}

@Model
class SearchTerms {
    
    var names: [String]
    
    init(names: [String]) {
        self.names = names
    }
}

@Model
class GameIds{
    var ids: [Int]
    
    init(ids: [Int]) {
        self.ids = ids
    }
}
	
