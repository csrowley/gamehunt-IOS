//
//  LocalDatabase+Migrator.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/7/24.
//

import Foundation
import GRDB

extension LocalDatabase {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("v1") { db in
            try createGamesCoversFranchisesTables(db)
        }
        
        return migrator
    }
    
    private func createGamesCoversFranchisesTables(_ db: GRDB.Database) throws {
        try db.create(table: "game") { table in
            table.column("id", .integer).primaryKey().notNull()
            table.column("name", .text).notNull()
            table.column("cover", .integer)
            table.column("franchise", .integer)
            table.column("release_date", .text)
            table.column("rating", .double)
            table.column("rating_count", .integer)
            
        }
        
        try db.create(table: "cover"){ table in
            table.column("cover_id", .integer).primaryKey().notNull()
            table.column("cover_url", .text)
            table.belongsTo("games", onDelete: .cascade)
        }
        
        
        try db.create(table: "franchise"){ table in
            table.column("franchise_id", .integer).notNull().primaryKey()
            table.column("name", .text)
        }
    }
}
