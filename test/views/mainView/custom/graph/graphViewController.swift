//
//  graphViewController.swift
//  test
//
//  Created by daniel martinez gonzalez on 24/3/18.
//

import UIKit

class graphViewController: UIViewController , ScrollableGraphViewDataSource{
    
    var graphView: ScrollableGraphView!
    var currentGraphType = GraphType.multiTwo
    var graphConstraints = [NSLayoutConstraint]()
    var numberOfDataItems = 8
    var maxValueOfDataItems = 50.0
    var maxNValueOfDataItems = -50.0
    
    var arrayMax : [Double] = [0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ]
    var arrayMin : [Double] = [0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ]
    
    var arraycounterMax : [Double] = [Double]()
    var arraycounterMin : [Double] = [Double]()
    
    lazy var blueLinePlotData: [Double] = self.initialValues()
    lazy var orangeLinePlotData: [Double] = self.initialValues()
    
    func initialValues() -> [Double] {
        var values = [Double]()
        for var i in 0..<14{
            values.append(4.0)
        }
        return values
    }
    
    var Timer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.graphView = self.createMultiPlotGraphTwo(self.view.frame)
        self.graphView.alpha = 0.6
        self.view.addSubview(self.graphView)
        self.setupConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.identifier) {
        case "multiBlue":
            return blueLinePlotData[pointIndex]
        case "multiBlueDot":
            return blueLinePlotData[pointIndex]
        case "multiOrange":
            return orangeLinePlotData[pointIndex]
        case "multiOrangeSquare":
            return orangeLinePlotData[pointIndex]
            
        default:
            return 0
        }
    }
    
    func numberOfPoints() -> Int {
        return numberOfDataItems
    }
    
    private func setupConstraints() {
        
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        graphConstraints.removeAll()
        
        let topConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        
        graphConstraints.append(topConstraint)
        graphConstraints.append(bottomConstraint)
        graphConstraints.append(leftConstraint)
        graphConstraints.append(rightConstraint)
        
        self.view.addConstraints(graphConstraints)
    }
    
    fileprivate func createMultiPlotGraphTwo(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        let blueLinePlot = LinePlot(identifier: "multiBlue")
        
        blueLinePlot.lineWidth = 1
        blueLinePlot.lineColor = UIColor.colorFromHex(hexString: "#ffffff").withAlphaComponent(1.0)
        blueLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        blueLinePlot.shouldFill = true
        blueLinePlot.fillType = ScrollableGraphViewFillType.solid
        blueLinePlot.fillColor = UIColor.colorFromHex(hexString: "#ffffff").withAlphaComponent(1.0)
        
        blueLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let orangeLinePlot = LinePlot(identifier: "multiOrange")
        
        orangeLinePlot.lineWidth = 1
        orangeLinePlot.lineColor = UIColor.colorFromHex(hexString: "#ff0000").withAlphaComponent(1.0)
        orangeLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        orangeLinePlot.shouldFill = true
        orangeLinePlot.fillType = ScrollableGraphViewFillType.solid
        orangeLinePlot.fillColor = UIColor.colorFromHex(hexString: "#ff0000").withAlphaComponent(1.0)
        
        orangeLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        graphView.backgroundFillColor = UIColor.clear
        graphView.dataPointSpacing = CGFloat(Int(self.view.frame.width) / numberOfDataItems)
        
        graphView.isScrollEnabled = false
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.shouldRangeAlwaysStartAtZero = true
        graphView.addPlot(plot: blueLinePlot)
        graphView.addPlot(plot: orangeLinePlot)
        graphView.bounces = false
        return graphView
    }
    
    // The type of the current graph we are showing.
    enum GraphType {
        case multiTwo
        
        mutating func next() {
            switch(self)
            {
            case .multiTwo:
                self = GraphType.multiTwo
            }
        }
    }
    
    func processValue(max:Double  , min:Double){
        let max = max * 5
        let min = min * 5
        
        arraycounterMin.append(min)
        arraycounterMax.append(max)
        
        if arraycounterMin.count >= 100 && arraycounterMax.count >= 100{
            self.calculateMaxMinValue(arrayMax: arraycounterMax , arrayMin: arraycounterMin)
            arraycounterMax = [Double]()
            arraycounterMin = [Double]()
        }
    }
    
    func calculateMaxMinValue(arrayMax: [Double] , arrayMin: [Double]){
        var maxValue : Double = 0
        var minValue : Double = 0
        
        for var i in 0..<arrayMax.count{
            let value = arrayMax[i]
            if value > 0{
                if value > maxValue{
                    maxValue = value
                    if maxValue > maxValueOfDataItems{
                        maxValue = maxValueOfDataItems
                    }
                }
            }
        }
        
        for var i in 0..<arrayMin.count{
            let value = arrayMin[i]
            if value < 0{
                if value < minValue{
                    minValue = value
                    if minValue < maxNValueOfDataItems{
                        minValue = maxNValueOfDataItems
                    }
                }
            }
        }
        
        self.arrayMax.append(maxValue)
        self.arrayMin.append(abs(minValue))
        
        if self.arrayMax.count > numberOfDataItems && self.arrayMin.count > numberOfDataItems{
            self.ReloadGraph()
        }
    }
    
    func ReloadGraph(){
        
        blueLinePlotData = self.arrayMin
        orangeLinePlotData = self.arrayMax
        
        graphView.reload()
        
        self.arrayMin = [Double]()
        self.arrayMax = [Double]()
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return ""
    }
    
    //MARK: MotionMAnagerDelegate
    
    func tracingMotionAcceleration(_ acceleration: NSDictionary) {
        self.processValue(max: 0.0, min: 0.0)
    }
    
    func tracingMotionRotation(_ rotation: NSDictionary) {
    }

}
