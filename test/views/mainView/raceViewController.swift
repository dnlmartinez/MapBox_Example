//
//  ViewController.swift
//  test
//
//  Created by daniel martinez gonzalez on 2/3/18.
//

import UIKit
import Mapbox

class raceViewController: UIViewController , MGLMapViewDelegate , TripRecorderManagerDelegate , CAAnimationDelegate  , UITableViewDelegate , UITableViewDataSource {
    
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var bt_Action: UIButton!
    @IBOutlet weak var view_Action: UIView!
    @IBOutlet weak var labelCrono: UILabel!
    @IBOutlet weak var viewStats: UIView!
    @IBOutlet weak var viewSpeed: UIView!
    @IBOutlet weak var labelSpeed: UILabel!
    @IBOutlet weak var viewCounter: UIView!
    @IBOutlet weak var imgCounterNumber: UIImageView!
    @IBOutlet weak var viewStateTrip: UIView!
    @IBOutlet weak var backgroundMeta: UIImageView!
    @IBOutlet weak var viewMeta: UIView!
    @IBOutlet weak var viewStats2: UIView!
    @IBOutlet weak var viewBack: UIView!
    
    @IBOutlet weak var tableTimes: UITableView!
    @IBOutlet weak var labelBestLap: UILabel!
    @IBOutlet weak var labelBestTime: UILabel!

    
    
    @IBOutlet weak var viewBestLap: UIView!
    @IBOutlet weak var labelViewBestLapNumber: UILabel!
    @IBOutlet weak var labelViewBestLapTime: UILabel!
    
    //@IBOutlet weak var viewGraph: UIView!
    
    var mapView: MGLMapView!
    var showInfoTrip : Bool = false
    var diff : Int = 0
    var oldLocation: CLLocation!
    var coordinates = [CLLocationCoordinate2D]()
    var arrayTimesLaps = [TimeInterval]()
    
    //let url = URL(string: "mapbox://styles/mapbox/light-v9")
    //let url = URL(string: "mapbox://styles/mapbox/satellite-v9")
    //let url = URL(string: "mapbox://styles/mapbox/satellite-streets-v10")
    let url = URL(string: "mapbox://styles/mapbox/dark-v9")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TripRecorderManager.sharedInstance.delegate = self
        TripRecorderManager.sharedInstance.initValues()
        
        self.loadMap()
        
        viewStats.layer.cornerRadius = 12.0
        viewStats.layer.borderColor = UIColor.white.cgColor
        viewStats.layer.borderWidth = 2.5
        viewStats.backgroundColor = UIColor.lightGray
        viewStats2.layer.cornerRadius = 12.0
        viewStats2.layer.borderColor = UIColor.white.cgColor
        viewStats2.layer.borderWidth = 2.5
        viewStats2.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        viewStats.isHidden = true
        viewStats2.isHidden = true
        viewBestLap.isHidden = true
        
        viewSpeed.layer.cornerRadius = 40.0
        viewSpeed.layer.borderColor = UIColor.white.cgColor
        viewSpeed.layer.borderWidth = 4.0
        viewSpeed.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        viewSpeed.isHidden = true
        viewCounter.isHidden = true
        
        viewStateTrip.layer.cornerRadius = 4.0
        viewStateTrip.layer.borderColor = UIColor.black.cgColor
        viewStateTrip.layer.borderWidth = 0.5
        viewStateTrip.backgroundColor = UIColor.green
        
        viewMeta.alpha = 0.0
        viewMeta.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        viewMeta.isUserInteractionEnabled = false
        
        tableTimes.delegate = self
        tableTimes.dataSource = self
        //redirectConsoleLogToDocumentFolder()
        
        self.labelCrono.addShining(color: .white, radius: 5.0 , opacity: 0.6)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadMap(){
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.isScrollEnabled = true
        mapView.isUserInteractionEnabled = true
        mapView.camera = MGLMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: 42.213762, longitude:  -8.739640), fromDistance: 600, pitch: 45, heading: 200)
        
        view.addSubview(mapView)
        view.bringSubview(toFront: viewMeta)
        view.bringSubview(toFront: background)
        view.bringSubview(toFront: view_Action)
        view.bringSubview(toFront: viewBack)
        view.bringSubview(toFront: viewStats2)
        view.bringSubview(toFront: viewStats)
        view.bringSubview(toFront: viewBestLap)
        view.bringSubview(toFront: viewSpeed)
        view.bringSubview(toFront: viewCounter)
    }
    
    func animateBestLap(lap:Int , time:String){
        if arrayTimesLaps.count > 1{
           self.viewBestLap.alpha = 0.0
           self.viewBestLap.isHidden = false
            UIView.animate(withDuration: 0.1, animations: {
                self.viewMeta.alpha = 1.0
            }, completion: { (success) in
                self.backgroundMeta.layer.add(helper_1.waterEffect(delegate: self), forKey: nil)
                UIView.animate(withDuration: 0.1, delay: 0.4 , options: UIViewAnimationOptions.curveEaseIn , animations: {
                    self.viewMeta.alpha = 0.0
                }, completion: { (success) in
                    self.labelViewBestLapNumber.text = "LAP \(lap)"
                    self.labelViewBestLapTime.text = time
                    
                    UIView.animate(withDuration: 0.2 , animations: {
                        self.viewBestLap.alpha = 1.0
                    }, completion: { (success) in
                        UIView.animate(withDuration: 2.0 , animations: {
                            self.viewBestLap.alpha = 0.0
                        }, completion: { (success) in
                            
                        })
                    })
                })
            })
            
        }
    }
    
    
    @IBAction func pressSaveTrip(_ sender: Any) {
        
        if !showInfoTrip{
            viewCounter.isHidden = false
            UIView.animate(withDuration: 0.0, animations: {
                self.viewCounter.alpha = 0.0
                self.viewCounter.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
            }, completion: { (success) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.viewCounter.alpha = 1.0
                    self.viewCounter.transform = CGAffineTransform.identity
                }, completion: { (success) in
                    self.imgCounterNumber.image = UIImage.init(named: "dos")
                    UIView.animate(withDuration: 0.0, animations: {
                        self.viewCounter.alpha = 0.0
                        self.viewCounter.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
                    }, completion: { (success) in
                        UIView.animate(withDuration: 0.5, animations: {
                            self.viewCounter.alpha = 1.0
                            self.viewCounter.transform = CGAffineTransform.identity
                        }, completion: { (success) in
                            self.imgCounterNumber.image = UIImage.init(named: "uno")
                            UIView.animate(withDuration: 0.0, animations: {
                                self.viewCounter.alpha = 0.0
                                self.viewCounter.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
                            }, completion: { (success) in
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.viewCounter.alpha = 1.0
                                    self.viewCounter.transform = CGAffineTransform.identity
                                }, completion: { (success) in
                                    // Start
                                    self.viewStateTrip.backgroundColor = UIColor.red
                                    self.viewCounter.isHidden = true
                                    self.imgCounterNumber.image = UIImage.init(named: "tres")
                                    self.showInfoTrip = true
                                    self.viewBack.isHidden = true
                                    self.viewSpeed.isHidden = false
                                    self.viewStats.isHidden = false
                                    //self.viewGraph.isHidden = false
                                    self.mapView.setUserTrackingMode(.follow, animated: true)
                                    self.mapView.isUserInteractionEnabled = false
                                    self.mapView.isScrollEnabled = false
                                    TripRecorderManager.sharedInstance.startTrip()
                                    //end
                                })
                            })
                        })
                    })
                })
            })
            
        }else{
            
            oldLocation = nil
            TripRecorderManager.sharedInstance.stopTrip()
            
            UIView.animate(withDuration: 0.2, animations: {
                self.viewMeta.alpha = 1.0
            }, completion: { (success) in
                self.backgroundMeta.layer.add(helper_1.waterEffect(delegate: self), forKey: nil)
                UIView.animate(withDuration: 0.5, delay: 2.0 , options: UIViewAnimationOptions.curveEaseIn , animations: {
                    
                    self.viewMeta.alpha = 0.0
                    
                }, completion: { (success) in
                    self.viewStateTrip.backgroundColor = UIColor.green
                    if self.mapView.annotations != nil{
                        let allAnnotations = self.mapView.annotations
                        self.mapView.removeAnnotations(allAnnotations!)
                    }
                    self.mapView.setUserTrackingMode(.follow, animated: true)
                    self.mapView.isUserInteractionEnabled = true
                    self.mapView.isScrollEnabled = true
                    self.viewBack.isHidden = false
                    self.viewStats.isHidden = true
                    self.viewSpeed.isHidden = true
                    self.viewCounter.isHidden = true
                    self.viewStats2.isHidden = true
                    //self.viewGraph.isHidden = true
                    self.showInfoTrip = false
                })
            })
        }
    }
    
    ///MARK: MAPBOX DELEGATE METHODS
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            if (castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        return annotationView
    }
    
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }
    
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(annotation, animated: false)
        let alert = UIAlertController(title: annotation.title!!, message: "A lovely (if touristy) place.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if let source = style.source(withIdentifier: "composite") {
            let layer = MGLFillExtrusionStyleLayer(identifier: "buildings", source: source)
            layer.sourceLayerIdentifier = "building"
            layer.predicate = NSPredicate(format: "extrude == 'true' AND height >= 0")
            layer.fillExtrusionHeight = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "height", options: nil)
            layer.fillExtrusionBase = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "min_height", options: nil)
            layer.fillExtrusionOpacity = MGLStyleValue(rawValue: 0.75)
            layer.fillExtrusionColor = MGLStyleValue(rawValue: .darkGray)
           
            if let symbolLayer = style.layer(withIdentifier: "poi-scalerank3") {
                style.insertLayer(layer, below: symbolLayer)
            } else {
                style.addLayer(layer)
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            if (!castAnnotation.willUseImage) {
                return nil;
            }
        }
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "salida")
        if(annotationImage == nil) {
            annotationImage = MGLAnnotationImage(image: UIImage(named: "salida")!, reuseIdentifier: "salida")
        }
        
        return annotationImage
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if let annotation = annotation as? CustomPolyline {
            return annotation.color ?? .orange
        }
        return mapView.tintColor
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 10
    }
    
    
    //MARK: TableViewDelegate && TableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayTimesLaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row + 1) - \(helper_1.valueTimeInString(time:self.arrayTimesLaps[indexPath.row]))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 11.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewW : UIView = UIView()
        viewW.backgroundColor = UIColor.clear
        return viewW
    }
    
    ///MARK: TripRecorderManager
    
    func notifyIsCircuit(_ data: NSDictionary) {
        let isCircuit : Bool = (data.object(forKey:"isCircuit") as! NSNumber).boolValue
        if isCircuit {
            
            let actualBestLap : String = self.labelBestLap.text!
            let newBestLap : String = "\((data.object(forKey:"bestLap") as! NSNumber).intValue)"
            
            if !actualBestLap.isEqual(newBestLap) {
                self.labelBestTime.text = data.object(forKey:"bestTimeLap") as! String
                self.labelBestLap.text = "\((data.object(forKey:"bestLap") as! NSNumber).intValue)"
                
                self.animateBestLap(lap:(data.object(forKey:"bestLap") as! NSNumber).intValue , time:self.labelBestLap.text!)
            }
            
            self.arrayTimesLaps = data.object(forKey: "timesLaps") as! [TimeInterval]
            self.tableTimes.reloadData()
            self.viewStats2.isHidden = false
        }
    }
    
    func notifyTimeCurrentLap(_ data: NSDictionary) {
        self.labelCrono.text = data.object(forKey: "currentLap") as! String
    }
    
    func tracingLocationTrip(_ currentLocation: CLLocation) {
        if showInfoTrip{
            if oldLocation != nil{
                let diff = currentLocation.distance(from: oldLocation)
                coordinates.append(currentLocation.coordinate)
                if diff > 10{
                    let polyline = CustomPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                    polyline.color = UIColor(hex: "#ff0000") //"#fc4181")
                    mapView.addAnnotation(polyline)
                    coordinates = [CLLocationCoordinate2D]()
                    coordinates.append(currentLocation.coordinate)
                    oldLocation = currentLocation
                }
            }else{
                let pointA = MyCustomPointAnnotation()
                pointA.coordinate = currentLocation.coordinate
                pointA.title = "Salida"
                pointA.willUseImage = true
                mapView.addAnnotation(pointA)
                oldLocation = currentLocation
            }
        }
    }
    
    func tracingLocationChangedInfoTrip(_ infoLocation: NSDictionary) {
        labelSpeed.text = infoLocation.object(forKey:"speed") as? String
    }
    
    @IBAction func pressBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}


//MARK: Custom Annotation Class

class MyCustomPointAnnotation: MGLPointAnnotation {
    var willUseImage: Bool = false
}

class CustomPolyline: MGLPolyline {
    var color: UIColor?
}

class CustomAnnotationView: MGLAnnotationView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scalesWithViewingDistance = true
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.add(animation, forKey: "borderWidth")
    }
    
}


