//
//  InfoViewPart.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 14/06/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import UIKit
import Charts

enum lineColor {
    static let temperature = UIColor(named: "temperatureLine")!
    static let humidity = UIColor(named: "humidityLine")!
    static let pressure = UIColor(named: "pressureLine")!
}

class InfoViewPart: UIView {
    
    @IBOutlet var view: InfoViewPart!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if self.subviews.count == 0 {
            UINib(nibName: "InfoViewTvOS", bundle: nil).instantiate(withOwner: self, options: nil)
            addSubview(view)
            view.frame = self.bounds
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populate(data: DataSet, label: String, description: String, lineColor: UIColor) {
        let line = LineChartDataSet(values: data.map({ (time: Date, value: Float) -> ChartDataEntry in
            return ChartDataEntry(x: Double(time.timeIntervalSince1970), y: Double(value))
        }), label: label)
        guard let _ = self.valueLabel, let _ = self.lineChartView else {
            debugPrint("UI not ready, adios")
            return
        }
        self.valueLabel.text = "\(data.last?.value ?? 0)"
        
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
        lineChartView.data = data
        lineChartView.setScaleEnabled(false)
        lineChartView.chartDescription?.font = UIFont.boldSystemFont(ofSize: 250.0)
        lineChartView.chartDescription?.text = description
        lineChartView.chartDescription?.textColor = UIColor(named: "textColor")!.withAlphaComponent(0.1)
        
        lineChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 15.0)
        lineChartView.xAxis.labelTextColor = UIColor(named:"textColor")!
        lineChartView.getAxis(.left).labelFont = UIFont.systemFont(ofSize: 15.0)
        lineChartView.getAxis(.right).labelFont = UIFont.systemFont(ofSize: 15.0)
        lineChartView.getAxis(.left).labelTextColor = UIColor(named:"textColor")!
        lineChartView.getAxis(.right).labelTextColor = UIColor(named:"textColor")!
        
        lineChartView.xAxis.valueFormatter = CustomDateFormatter()
        lineChartView.backgroundColor = UIColor(named: "background")!
        lineChartView.gridBackgroundColor = UIColor(named: "background")!
        lineChartView.legend.textColor = UIColor(named: "textColor")!
        lineChartView.legend.font = UIFont.systemFont(ofSize: 15.0)
    }
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
