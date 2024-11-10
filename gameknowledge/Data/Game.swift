//
//  Game.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/8/24.
//

import Foundation
import GRDB


struct Game: Identifiable, Codable {
    var id: Int64
    var name: String
    var cover: Int64
    var franchise: String?
    var release_date: String
    var rating: Double
    var rating_count: Int64
}

extension Game: EncodableRecord, FetchableRecord {}

extension Game: TableRecord {
    static let covers = hasOne(Cover.self)
    
    var covers: QueryInterfaceRequest<Cover> {
        request(for: Game.covers)
    }
}

extension Game: PersistableRecord {}

