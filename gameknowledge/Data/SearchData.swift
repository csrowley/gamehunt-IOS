//
//  SearchData.swift
//  gameknowledge
//
//  Created by Chris Rowley on 10/7/24.
//
import SwiftData

@Model
class SearchTerms {
    var names: [String]
    
    init(names: [String]) {
        self.names = names
    }
}
	
