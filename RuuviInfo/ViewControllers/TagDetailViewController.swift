//
//  DetailViewController.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 04/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Charts

class TagDetailViewController: UIViewController {
    
    @IBOutlet weak var temperatureView: LineChartView!
    @IBOutlet weak var humidityView: LineChartView!
    @IBOutlet weak var pressureView: LineChartView!
    
    fileprivate lazy var appDelegate: AppDelegate = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("No AppDelegate available???")
        }
        return delegate
    }()
    
    fileprivate lazy var viewModel: RuuviTagDetailViewModelProtocol = {
        return RuuviTagDetailViewModel(dataUpdated: { graphModel in
            self.populate(data: graphModel.temperature, to: self.temperatureView, label: "Celsius", description: "Temperature")
            self.populate(data: graphModel.humidity, to: self.humidityView, label: "Percentage", description: "Humidity")
            self.populate(data: graphModel.pressure, to: self.pressureView, label: "mBar", description: "Pressure")
        })
    }()
    
    var context: NSManagedObjectContext!
    var tag: RuuviTag!
    var tagRepository: TagRepositoryProtocol!
    var graphModel: SensorGraphModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = tag.customName ?? tag.uuid?.uuidString
        viewModel.loadTagInfo(uuid: tag.uuid!)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: Notification.Name.ruuviData, object: nil)
    }
    
    @objc private func dataChanged(){
        viewModel.loadTagInfo(uuid: tag.uuid!)
    }
    
    
    private func populate(data: DataSet, to view: LineChartView, label: String, description: String) {
        let line = LineChartDataSet(values: data.map({ (time: Date, value: Float) -> ChartDataEntry in
            return ChartDataEntry(x: Double(time.timeIntervalSince1970), y: Double(value))
        }), label: label)
        
        line.colors = [UIColor.blue]
        // line.circleRadius = 2.0
        line.drawCirclesEnabled = false
        line.mode = .linear
        
        let data = LineChartData()
        data.addDataSet(line)
        data.setDrawValues(true)
        view.data = data
        view.setScaleEnabled(false)
        view.chartDescription?.text = description
        view.xAxis.valueFormatter = CustomDateFormatter()
    }
}

extension Notification.Name {
    static let ruuviData = Notification.Name("RuuviData")
}

fileprivate class CustomDateFormatter: IAxisValueFormatter {
    
    static let localFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return CustomDateFormatter.localFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}


