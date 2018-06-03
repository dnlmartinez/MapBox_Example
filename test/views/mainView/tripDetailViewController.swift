//
//  tripDetailViewController.swift
//  test
//
//  Created by daniel martinez gonzalez on 31/3/18.
//

import UIKit
import RealmSwift
import Mapbox


class tripDetailViewController: UIViewController , MGLMapViewDelegate {

    @IBOutlet weak var constrainHeightContentView: NSLayoutConstraint!
    @IBOutlet weak var viewMap: UIView!
    
    @IBOutlet weak var viewContainerMapInfo: UIView!
    @IBOutlet weak var gradianBackground: UIImageView!
    
    var mapView: MGLMapView!
    var trip : realmTrip!
    
    var allCoordinates: [CLLocationCoordinate2D]!
    var timer: Timer?
    var polylineSource: MGLShapeSource?
    var currentIndex = 1
    
    //let url = URL(string: "mapbox://styles/mapbox/light-v9")
    //let url = URL(string: "mapbox://styles/mapbox/satellite-v9")
    //let url = URL(string: "mapbox://styles/mapbox/satellite-streets-v10")
    let url = URL(string: "mapbox://styles/mapbox/dark-v9")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allCoordinates = coordinates()
        
        let maxSpeed : Double = trip.maxSpeedValue()
        let minSpeed : Double = trip.minSpeedValue()
        let speedAvg : Double = trip.tripSpeedAverage()
        
        //NSLog(" ================  \nMaxSpeed:\(maxSpeed) \nMinSpeed:\(minSpeed) \nAvg:\(speedAvg) \n==============")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        let screenSize = UIScreen.main.bounds
        self.constrainHeightContentView.constant = screenSize.height
        self.loadMap()
    }
    
    func loadMap(){
        mapView = MGLMapView(frame: viewMap.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isScrollEnabled = true
        mapView.isUserInteractionEnabled = true

        mapView.setCenter(CLLocationCoordinate2D(latitude: (trip.startLocation?.latitud)!, longitude: (trip.startLocation?.longitud)!) , zoomLevel: 14.8 , animated: true)
        
        mapView.delegate = self
        mapView.reloadInputViews()
        viewMap.addSubview(mapView)
        viewContainerMapInfo.bringSubview(toFront: gradianBackground)
    }
    
    //MARK: MapBox Delegate
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        addLayer(to: style)
        animatePolyline()
    }
    
    func addLayer(to style: MGLStyle) {
        
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
        
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        layer.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .round))
        layer.lineColor = MGLStyleValue(rawValue: UIColor.red)
        layer.lineWidth = MGLStyleFunction(interpolationMode: .exponential,
                                           cameraStops: [14: MGLConstantStyleValue<NSNumber>(rawValue: 5),
                                                         18: MGLConstantStyleValue<NSNumber>(rawValue: 20)],
                                           options: [.defaultValue : MGLConstantStyleValue<NSNumber>(rawValue: 1.5)])
        style.addLayer(layer)
    }
    
    func animatePolyline() {
        currentIndex = 1
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        if currentIndex > allCoordinates.count {
            timer?.invalidate()
            timer = nil
            return
        }
        let coordinates = Array(allCoordinates[0..<currentIndex])
        updatePolylineWithCoordinates(coordinates: coordinates)
        currentIndex += 1
    }
    
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        polylineSource?.shape = polyline
    }
    
    func coordinates() -> [CLLocationCoordinate2D] {
        return trip.getRouteInLocationCoordinates()
    }
    
    //MARK: Button Back
    
    @IBAction func pressBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
