//
//  LocalDatabase.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/8/24.
//

import Foundation
import GRDB
import Combine

struct LocalDatabase{
    private let writer: DatabaseWriter
    
    init(_ writer: DatabaseWriter) throws {
        self.writer = writer
        try migrator.migrate(writer)
    }
    
    var reader: DatabaseReader {
        writer
    }
    
}
// MARK: - Writes
extension LocalDatabase {
    func createGame(_ game: Game) async throws {
        try await writer.write({db in
            try game.insert(db)
        })
    }
    
    func createCover(_ cover: Cover) async throws {
        try await writer.write({db in
            try cover.insert(db)
        })
    }
}

// MARK: - Observe
extension LocalDatabase{
    func observeGames() -> AnyPublisher<[Game], Error> {
        let observation = ValueObservation.tracking { db in
            return try Game.fetchAll(db)
        }
        
        let publisher = observation.publisher(in: reader)
        return publisher.eraseToAnyPublisher()
    }
}

// MARK: - Reads

extension LocalDatabase{
    func getCoverForGame(_ game: Game) async throws -> [Cover] {
        try await reader.read({db in
            let covers = try game.covers.fetchAll(db)
            return covers
            
        })
    }
}

extension LocalDatabase {
    struct ImportError: Error {
        let message: String
    }

    func importAllData() async throws {
        // Import games first since covers depend on them
        try await importGamesFromFile()
        try await importCoversFromFile()
        try await importFranchisesFromFile()
        print("✅ Database import completed successfully")
    }

    private func importGamesFromFile() async throws {
        guard let url = Bundle.main.url(forResource: "games_rows", withExtension: "json") else {
            throw ImportError(message: "Could not find games_rows.json")
        }

        let jsonData = try Data(contentsOf: url)
        
        try await writer.write { db in
            do {
                let games = try JSONDecoder().decode([Game].self, from: jsonData)
                print("📥 Importing \(games.count) games...")

                for game in games {
                    try game.insert(db)
                }

                print("✅ Games import successful")
            } catch {
                print("❌ Games import failed: \(error)")
                throw error  // Re-throw the error to ensure it exits the transaction
            }
        }
    }

    private func importCoversFromFile() async throws {
        guard let url = Bundle.main.url(forResource: "covers_rows", withExtension: "json") else {
            throw ImportError(message: "Could not find cover_rows.json")
        }

        let jsonData = try Data(contentsOf: url)
        
        try await writer.write { db in
            do {
                let covers = try JSONDecoder().decode([Cover].self, from: jsonData)
                print("📥 Importing \(covers.count) covers...")

                for cover in covers {
                    try cover.insert(db)
                }

                print("✅ Covers import successful")
            } catch {
                print("❌ Covers import failed: \(error)")
                throw error  // Re-throw the error to ensure it exits the transaction
            }
        }
    }
    
    
    private func importFranchisesFromFile() async throws {
        guard let url = Bundle.main.url(forResource: "franchises_rows", withExtension: "json") else {
            throw ImportError(message: "franchises_rows not found, error loading")
        }
        
        let jsonData = try Data(contentsOf: url)
        
        try await writer.write{ db in
            do{
                let franchises = try JSONDecoder().decode([Franchise].self, from: jsonData)
                print("📥 Importing \(franchises.count) franchises...")
                
                for franchise in franchises {
                    try franchise.insert(db)
                }
                print("✅ Covers import successful")
                
            } catch {
                print("❌ Franchises import failed: \(error)")
                throw error  // Re-throw the error to ensure it exits the transaction
            }
        }
    }
    
}

// MARK: - Usage Example
extension LocalDatabase {
    static func populateDatabase() async {
        do {
            print("Starting database population ...")
            try await shared.importAllData()
        } catch {
            print("DB population failed: \(error)")
        }
    }
}



// MARK: - Read Queries
extension LocalDatabase {
    // Get game by its ID
    
    func getGame(id: Int64) async throws -> Game? {
        try await reader.read {db in
            try Game
                .filter(Column("id") ==  id)
                .fetchOne(db)
        }
    }
    
    func getCover(id: Int64) async throws -> Cover? {
        try await reader.read {db in
            try Cover
                .filter(Column("cover_id") == id)
                .fetchOne(db)
        }
    }
    
    func getFranchise(id: Int64) async throws -> Franchise? {
        try await reader.read {db in
            try Franchise
                .filter(Column("id") == id)
                .fetchOne(db)
        }
    }
}
