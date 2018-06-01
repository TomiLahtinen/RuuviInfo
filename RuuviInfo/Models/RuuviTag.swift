//
//  RuuviTag.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 31/05/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation

struct RuuviTag: Equatable {
    
    let UUID: String
    let name: String
    
    let info: TagInfo?
    
}

func ==(lhs: RuuviTag, rhs: RuuviTag) -> Bool {
    return lhs.UUID == rhs.UUID
}
