//
//  DataFormat3.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 01/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import SwiftBytes

enum DataConstants {
    static let RuuviManufacturerID = 39172
}

struct DataFormat3 {
    
    let manufacturer: UInt16
    let version: UInt8
    let humidity: UInt8
    let temperatureWhole: Int8
    let temperatureFraction: UInt8
    let pressure: UInt16
    let accelerationX: Int16
    let accelerationY: Int16
    let accelerationZ: Int16
    let voltage: UInt16
    
    static func decode(data: Data?) -> DataFormat3? {
        guard let dataBytes = data?.bytes else {
            return nil
        }
        if dataBytes.count != 20 {
            return nil
        }
        let result = DataFormat3(
        manufacturer: concatenateBytes(dataBytes[0], dataBytes[1]),
        version: dataBytes[2],
        humidity: dataBytes[3],
        temperatureWhole: signed(dataBytes[4]),
        temperatureFraction: dataBytes[5],
        pressure: concatenateBytes(dataBytes[6], dataBytes[7]),
        accelerationX: signed(concatenateBytes(dataBytes[8], dataBytes[9])),
        accelerationY: signed(concatenateBytes(dataBytes[10], dataBytes[11])),
        accelerationZ: signed(concatenateBytes(dataBytes[12], dataBytes[13])),
        voltage: concatenateBytes(dataBytes[14], dataBytes[15]))
        if result.manufacturer == DataConstants.RuuviManufacturerID {
            debugPrint("Pressure bytes", dataBytes[6], dataBytes[7]) // 0xC2, 0xDB
            return result
        }
        else {
            return nil
            
        }
    }
}


extension SensorValues {
    func insert(data rawData: DataFormat3) {
        self.humidity = Int16(rawData.humidity) / 2
        self.temperature = Float(rawData.temperatureWhole) + (Float(rawData.temperatureFraction) / 100.0)
        self.pressure = Int32(rawData.pressure + 50000)
        debugPrint("Parsed pressure", self.pressure)
        self.accelerationX = Int16(rawData.accelerationX)
        self.accelerationY = Int16(rawData.accelerationY)
        self.accelerationZ = Int16(rawData.accelerationZ)
        self.voltage = Int16(rawData.voltage)
    }
}
