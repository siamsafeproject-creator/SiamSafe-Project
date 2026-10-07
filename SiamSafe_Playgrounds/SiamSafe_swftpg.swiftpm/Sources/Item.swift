//
//  Item.swift
//  SiamSafe
//
//  Created by Theeraphon Klinrung on 2/10/2569 BE.
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
