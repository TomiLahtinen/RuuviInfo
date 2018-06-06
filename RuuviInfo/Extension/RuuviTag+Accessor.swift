//
//  RuuviTag+Accessor.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 01/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation

extension RuuviTag {
    
    func getInt(by propertyName: String) -> String? {
        return value(forKey: propertyName) as? String
    }
    
    func getInt16(by propertyName: String) -> Int16? {
        return value(forKey: propertyName) as? Int16
    }
    
    func getInt(by propertyName: String) -> Int32? {
        return value(forKey: propertyName) as? Int32
    }
    
    func getFloat(by propertyName: String) -> Float? {
        return value(forKey: propertyName) as? Float
    }
}
