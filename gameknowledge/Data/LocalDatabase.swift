//
//  LocalDatabase.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/8/24.
//

import Foundation
import GRDB

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
