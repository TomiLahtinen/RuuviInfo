//
//  DetailViewController.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 04/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import UIKit

class TagDetailViewController: UIViewController {
    
    var tag: RuuviTag!
    var tagRepository: TagRepositoryProtocol!
    var graphModel: SensorGraphModel!
    
    @IBOutlet weak var temperatureView: InfoViewPart!
    @IBOutlet weak var humidityView: InfoViewPart!
    @IBOutlet weak var pressureView: InfoViewPart!
    
    fileprivate lazy var viewModel: RuuviTagDetailViewModelProtocol = {
        return RuuviTagDetailViewModel(dataUpdated: { graphModel in
            DispatchQueue.main.async {
                self.temperatureView.populate(data: graphModel.temperature, label: "Celsius", description: "Temperature", lineColor: lineColor.temperature)
                self.humidityView.populate(data: graphModel.humidity, label: "Percentage", description: "Humidity", lineColor: lineColor.humidity)
                self.pressureView.populate(data: graphModel.pressure, label: "hPa", description: "Pressure", lineColor: lineColor.pressure)
            }
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = tag.customName ?? tag.uuid?.uuidString
        viewModel.loadTagInfo(uuid: tag.uuid!)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: Notification.Name.ruuviData, object: nil)
    }
    
    @objc private func dataChanged(){
        viewModel.loadTagInfo(uuid: tag.uuid!)
    }
}

extension Notification.Name {
    static let ruuviData = Notification.Name("RuuviData")
}


