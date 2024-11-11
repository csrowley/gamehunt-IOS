//
//  Cover.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/8/24.
//

//add franchise hints
// add daily streak
// add coins?
// add tutorial ?
// add hint that will unblur a specific part of the picture

import Foundation
import GRDB

struct Cover: Identifiable, Codable {
    var cover_id: Int64?
    var cover_url: String
    
    
    var id: Int64? { cover_id }
}

extension Cover: TableRecord, FetchableRecord, EncodableRecord, PersistableRecord{}


