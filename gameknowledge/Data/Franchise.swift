//
//  Franchise.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/9/24.
//

import Foundation
import GRDB

struct Franchise: Identifiable, Codable {
    var id: Int64?
    var name: String
}


extension Franchise: TableRecord, FetchableRecord, EncodableRecord, PersistableRecord {}
