//
//  ViewController.swift
//  test
//
//  Created by daniel martinez gonzalez on 2/3/18.
//

import UIKit
import Mapbox

import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections



class ViewController: UIViewController , MGLMapViewDelegate , LocationServiceDelegate{
    
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
    
    
    var mapView: NavigationMapView!
    var showInfoTrip : Bool = false
    
    var diff : Int = 0
    var oldLocation: CLLocation!
    var coordinates = [CLLocationCoordinate2D]()
    var coordinatesSaved = [CLLocationCoordinate2D]()
    var statsSaved = NSMutableArray()
    
    var direction : String = ""
    var distance : String = ""
    var hightSpeed : String = ""
    var lowSpeed : String = ""
    var AvgSpeed : String = ""
    
    var timerStart = Timer()
    var startTimeInterval = TimeInterval()
    
    var enableCheckCircuit : Bool = false
    var firstLocation : CLLocation!
    var positionFirstLocation : String = "N"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadMap()
        
        viewStats.layer.cornerRadius = 12.0
        viewStats.layer.borderColor = UIColor.white.cgColor
        viewStats.layer.borderWidth = 2.5
        viewStats.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        viewStats.isHidden = true
        
        
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
        
        //redirectConsoleLogToDocumentFolder()
    }

    
    func redirectConsoleLogToDocumentFolder() {
        var paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory: NSString = paths[0] as! NSString
        
        let name: String = "console_\(NSDate().timeIntervalSince1970).log"
        let logPath: NSString = documentsDirectory.appendingPathComponent(name) as NSString
        let cstr = (logPath as NSString).utf8String
        
        freopen(cstr, "a+", stderr)
    }
    
    
    
    func startTimer(){
        startTimeInterval = NSDate.timeIntervalSinceReferenceDate
        timerStart = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            
            let currentTime = NSDate.timeIntervalSinceReferenceDate
            var elapsedTime: TimeInterval = currentTime - self.startTimeInterval
            
            let minutes = UInt8(elapsedTime / 60.0)
            elapsedTime -= (TimeInterval(minutes) * 60)
            
            let seconds = UInt8(elapsedTime)
            elapsedTime -= TimeInterval(seconds)
            
            let fraction = UInt8(elapsedTime * 100)
            
            let strMinutes = String(format: "%02d", minutes)
            let strSeconds = String(format: "%02d", seconds)
            let strFraction = String(format: "%02d", fraction)
            
            self.labelCrono.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func loadMap(){
        //let url = URL(string: "mapbox://styles/mapbox/light-v9")
        //let url = URL(string: "mapbox://styles/mapbox/satellite-v9")
        //let url = URL(string: "mapbox://styles/mapbox/satellite-streets-v10")
        let url = URL(string: "mapbox://styles/mapbox/dark-v9")
        
        mapView = NavigationMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.camera = MGLMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: 42.213762, longitude:  -8.739640), fromDistance: 600, pitch: 45, heading: 200)
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.isUserInteractionEnabled = true
        
        view.addSubview(mapView)
        view.bringSubview(toFront: background)
        view.bringSubview(toFront: view_Action)
        view.bringSubview(toFront: viewStats)
        view.bringSubview(toFront: viewSpeed)
        view.bringSubview(toFront: viewCounter)
        
        mapView.isScrollEnabled = true
        LocationService.sharedInstance.delegate = self
        LocationService.sharedInstance.cleanValuesInfo()
        LocationService.sharedInstance.startUpdatingLocation()
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
        // Hide the callout view.
        mapView.deselectAnnotation(annotation, animated: false)
        
        // Show an alert containing the annotation's details
        let alert = UIAlertController(title: annotation.title!!, message: "A lovely (if touristy) place.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        // Access the Mapbox Streets source and use it to create a `MGLFillExtrusionStyleLayer`. The source identifier is `composite`. Use the `sources` property on a style to verify source identifiers.
        if let source = style.source(withIdentifier: "composite") {
            let layer = MGLFillExtrusionStyleLayer(identifier: "buildings", source: source)
            layer.sourceLayerIdentifier = "building"
            
            // Filter out buildings that should not extrude.
            layer.predicate = NSPredicate(format: "extrude == 'true' AND height >= 0")
            
            // Set the fill extrusion height to the value for the building height attribute.
            layer.fillExtrusionHeight = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "height", options: nil)
            layer.fillExtrusionBase = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "min_height", options: nil)
            layer.fillExtrusionOpacity = MGLStyleValue(rawValue: 0.75)
            layer.fillExtrusionColor = MGLStyleValue(rawValue: .darkGray)
            
            // Insert the fill extrusion layer below a POI label layer. If you aren’t sure what the layer is called, you can view the style in Mapbox Studio or iterate over the style’s layers property, printing out each layer’s identifier.
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
                                        self.viewSpeed.isHidden = false
                                        self.viewStats.isHidden = false
                                        LocationService.sharedInstance.cleanValuesInfo()
                                        self.mapView.setUserTrackingMode(.follow, animated: true)
                                        self.mapView.isUserInteractionEnabled = false
                                        self.mapView.isScrollEnabled = false
                                        self.startTimer()
                                        //end
                                    })
                                })
                            })
                        })
                    })
            })
            
        }else{
        
            self.storeTrip(trip:coordinatesSaved)
            coordinatesSaved = [CLLocationCoordinate2D]()
            oldLocation = nil
            viewStateTrip.backgroundColor = UIColor.green
            
            let allAnnotations = mapView.annotations
            mapView.removeAnnotations(allAnnotations!)
            mapView.setUserTrackingMode(.follow, animated: true)
            mapView.isUserInteractionEnabled = true
            mapView.isScrollEnabled = true
            viewStats.isHidden = true
            viewSpeed.isHidden = true
            viewCounter.isHidden = true
            showInfoTrip = false
            enableCheckCircuit = false
        }
    }
    
    
    func storeTrip(trip: [CLLocationCoordinate2D] ){
        
        if coordinatesSaved.count > 10{
            for var i in 0 ..< coordinatesSaved.count{
                NSLog("\n \(coordinatesSaved[i].latitude)-\(coordinatesSaved[i].longitude) \n")
            }
            for var i in 0 ..< statsSaved.count{
                NSLog("\n \(statsSaved[i]) \n")
            }
        }
    }
    
    
    func createSnapshotStats(){
        
        let dictStats : [String : String] = [
                                            "direction" : direction ,
                                            "distance" : distance ,
                                            "hightSpeed" : hightSpeed ,
                                            "lowSpeed" : lowSpeed ,
                                            "AvgSpeed" : AvgSpeed
                                            ]
        self.statsSaved.add(dictStats)
    }
    
    
    func checkCircuitNear(currentLocation: CLLocation){
        if firstLocation != nil{
            let diff = currentLocation.distance(from: firstLocation)
            if diff < 5 && positionFirstLocation == direction {
                
                NSLog("Otra Vuelta")
                
            }
        }
    }
    
    
    ///MARK: Location Manager
    func tracingLocation(_ currentLocation: CLLocation) {
        if showInfoTrip{
            if oldLocation != nil{
                let diff = currentLocation.distance(from: oldLocation)
                coordinates.append(currentLocation.coordinate)
                if enableCheckCircuit{
                    checkCircuitNear(currentLocation:currentLocation)
                }
                
                if diff > 10{
                    enableCheckCircuit = true
                    coordinatesSaved.append(currentLocation.coordinate)
                    createSnapshotStats()
                    let polyline = CustomPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                    polyline.color = UIColor(hex: "#fc4181")
                    mapView.addAnnotation(polyline)
                    coordinates = [CLLocationCoordinate2D]()
                    coordinates.append(currentLocation.coordinate)
                    oldLocation = currentLocation
                }
            }else{
                //let Salida = MGLPointAnnotation()
                //Salida.coordinate = currentLocation.coordinate
                //Salida.title = "Salida"
                //mapView.addAnnotation(Salida)
                
                let pointA = MyCustomPointAnnotation()
                pointA.coordinate = currentLocation.coordinate
                pointA.title = "Salida"
                pointA.willUseImage = true
                mapView.addAnnotation(pointA)
                
                
                firstLocation = currentLocation
                positionFirstLocation = direction
                coordinatesSaved.append(currentLocation.coordinate)
                oldLocation = currentLocation
            }
        }
    }
    
    func tracingLocationChangedInfo(_ infoLocation: NSDictionary) {
        
        direction = infoLocation.object(forKey:"direction") as! String
        distance = infoLocation.object(forKey:"distance") as! String
        hightSpeed = infoLocation.object(forKey:"hightSpeed") as! String
        lowSpeed = infoLocation.object(forKey:"lowSpeed") as! String
        AvgSpeed = "\((infoLocation.object(forKey:"speedAvg") as! NSNumber).intValue) metros"
    
        labelSpeed.text = infoLocation.object(forKey:"speed") as? String
    }
}

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


