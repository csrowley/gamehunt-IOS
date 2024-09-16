//
//  Item.swift
//  gameknowledge
//
//  Created by Chris Rowley on 9/15/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
