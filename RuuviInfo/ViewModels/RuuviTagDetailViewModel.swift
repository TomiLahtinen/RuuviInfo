//
//  RuuviTagDetailViewModel.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 05/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import Charts

protocol RuuviTagDetailViewModelProtocol {
    init(dataUpdated: @escaping (SensorGraphModel) -> ())
    func loadTagInfo(uuid: UUID)
}

class RuuviTagDetailViewModel: RuuviTagDetailViewModelProtocol {

    let dataUpdated: (SensorGraphModel) -> ()
    let tagRepository: TagRepository
    
    required init(dataUpdated: @escaping (SensorGraphModel) -> ()) {
        self.dataUpdated = dataUpdated
        self.tagRepository = TagRepository()
    }
    
    func loadTagInfo(uuid: UUID) {
        var graphModel = SensorGraphModel()
        let tag = tagRepository.fetchTag(with: uuid)
        guard let _ = tag else {
            return
        }
        tag?.sensorValues?
            .sorted { (value1, value2) in
                guard let value1 = value1 as? SensorValues,
                    let value2 = value2 as? SensorValues else {
                        return false
                }
                return value1.timestamp! < value2.timestamp!
            }
            .suffix(200) // Last 20 measurements
            .forEach { value in
                guard let value = value as? SensorValues else {
                    fatalError("Something is terribly wrong with sensor values")
                }
                graphModel.temperature.append((time: value.timestamp!, value: value.temperature))
                graphModel.humidity.append((time: value.timestamp!, value: Float(value.humidity)))
                graphModel.pressure.append((time: value.timestamp!, value: Float(value.pressure)))
            }
        self.dataUpdated(graphModel)
    }
    
}
