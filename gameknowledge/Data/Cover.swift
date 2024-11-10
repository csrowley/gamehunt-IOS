//
//  Cover.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/8/24.
//

import Foundation
import GRDB

struct Cover: Identifiable, Codable {
    var cover_id: Int64?
    var cover_url: String
    
    
    var id: Int64? { cover_id }
}

extension Cover: TableRecord, FetchableRecord, EncodableRecord, PersistableRecord{}


