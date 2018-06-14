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
    
    enum lineColor {
        static let temperature = UIColor(named: "temperatureLine")!
        static let humidity = UIColor(named: "humidityLine")!
        static let pressure = UIColor(named: "pressureLine")!
        
    }
    
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
            DispatchQueue.main.async {
                self.populate(data: graphModel.temperature, to: self.temperatureView, label: "Celsius", description: "Temperature", lineColor: lineColor.temperature)
            }
            DispatchQueue.main.async {
                self.populate(data: graphModel.humidity, to: self.humidityView, label: "Percentage", description: "Humidity", lineColor: lineColor.humidity)
            }
            DispatchQueue.main.async {
                self.populate(data: graphModel.pressure, to: self.pressureView, label: "hPa", description: "Pressure", lineColor: lineColor.pressure)
            }
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
    
    
    private func populate(data: DataSet, to view: LineChartView, label: String, description: String, lineColor: UIColor) {
        let line = LineChartDataSet(values: data.map({ (time: Date, value: Float) -> ChartDataEntry in
            return ChartDataEntry(x: Double(time.timeIntervalSince1970), y: Double(value))
        }), label: label)
        
        // line.colors = [UIColor.red]
        // line.circleRadius = 2.0
        line.drawCirclesEnabled = false
        line.mode = .horizontalBezier
        line.lineWidth = 3.5
        line.setColor(lineColor, alpha: 0.95)
        line.fillAlpha = 0.7
        
        let data = LineChartData()
        data.addDataSet(line)
        data.setDrawValues(true)
        view.data = data
        view.setScaleEnabled(false)
        view.chartDescription?.font = UIFont.boldSystemFont(ofSize: 250.0)
        view.chartDescription?.text = description
        view.chartDescription?.textColor = UIColor(named: "textColor")!.withAlphaComponent(0.1)
        
        view.xAxis.labelFont = UIFont.systemFont(ofSize: 15.0)
        view.xAxis.labelTextColor = UIColor(named:"textColor")!
        view.getAxis(.left).labelFont = UIFont.systemFont(ofSize: 15.0)
        view.getAxis(.right).labelFont = UIFont.systemFont(ofSize: 15.0)
        view.getAxis(.left).labelTextColor = UIColor(named:"textColor")!
        view.getAxis(.right).labelTextColor = UIColor(named:"textColor")!
        
        view.xAxis.valueFormatter = CustomDateFormatter()
        view.backgroundColor = UIColor(named: "background")!
        view.gridBackgroundColor = UIColor(named: "background")!
        view.legend.textColor = UIColor(named: "textColor")!
        view.legend.font = UIFont.systemFont(ofSize: 15.0)
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


