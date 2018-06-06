//
//  RuuviTag.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 31/05/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation

func ==(lhs: RuuviTag, rhs: RuuviTag) -> Bool {
    return lhs.uuid?.uuidString == rhs.uuid?.uuidString
}
