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
class SearchTerms: Identifiable {
    @Attribute(.unique) var key: UUID
    var data: [SearchData]
    
    init(data: [SearchData], key: UUID = UUID()) {
        self.key = key
        self.data = data
    }
}

@Model
class SearchData: Identifiable{
    @Attribute(.unique) var uid: UUID
    var name: String
    var id: Int64
    
    init(name: String, id: Int64, uid: UUID = UUID()) {
        self.uid = uid
        self.name = name
        self.id = id
    }
}


