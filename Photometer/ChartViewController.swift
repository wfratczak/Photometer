//
//  ChartViewController.swift
//  Photometer
//
//  Created by Wojtek Frątczak on 15.11.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class ChartViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chart: LineChartView!
    private var currentMeter: Meter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModel()
        configureChart()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChart()
    }
    
    private func configureModel() {
        let realm = try! Realm()
        let meters = Array(realm.objects(Meter.self))
        currentMeter = meters.first
    }
    
    private func configureChart() {
        guard let meter = currentMeter else {
            return
        }
        titleLabel.text = "Meter: " + meter.name
        setupLeftAxis()
        setupXAxis()
        setupRightAxis()
        setupChartAppearace()
    }
 
    private func updateChart() {
        guard let meter = currentMeter else {
            return
        }
        var chartDataEntries: [ChartDataEntry] = []
        for value in meter.values {
            let xValue = value.createdAt.timeIntervalSince1970
            let entry = ChartDataEntry(x: xValue, y: value.value)
            chartDataEntries.append(entry)
        }
        let dataSet = LineChartDataSet(values: chartDataEntries, label: "Meter values")
        let chartData = LineChartData(dataSet: dataSet)
        chart.data = chartData
        chart.notifyDataSetChanged()
    }
    
    private func setupLeftAxis() {
        let leftAxis = chart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
    }
    
    private func setupRightAxis() {
        let rightAxis = chart.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawAxisLineEnabled = false
    }
    
    private func setupXAxis() {
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.valueFormatter = AxisDateFormatter()
    }
    
    private func setupChartAppearace() {
        chart.chartDescription?.text = ""
        chart.legend.enabled = false
        chart.noDataText = ""
    }
}

class AxisDateFormatter: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy H:mm"
        return dateFormatter.string(from: date)
    }
}
