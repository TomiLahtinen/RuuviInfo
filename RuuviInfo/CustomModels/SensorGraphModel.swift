//
//  SensorGraphModel.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 05/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation

typealias DataSet = [(time: Date, value: Float)]

struct SensorGraphModel {
    
    var temperature: DataSet = []
    var humidity: DataSet = []
    var pressure: DataSet = []
    
}
