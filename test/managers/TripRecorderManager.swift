//
//  TripRecorderManager.swift
//  test
//
//  Created by daniel martinez gonzalez on 26/3/18.
//

import UIKit
import CoreLocation


protocol TripRecorderManagerDelegate{
    func notifyIsCircuit(_ data: NSDictionary)
    func notifyTimeCurrentLap(_ data: NSDictionary)
    func tracingLocationTrip(_ currentLocation: CLLocation)
    func tracingLocationChangedInfoTrip(_ infoLocation: NSDictionary)
}

class TripRecorderManager: NSObject  , LocationServiceDelegate , MotionServiceDelegate {
    

    static let sharedInstance: TripRecorderManager =
    {
        let instance = TripRecorderManager()
        return instance
    }()
    
    var delegate: TripRecorderManagerDelegate?
    
    var enableTrip : Bool = false
    var enableCheckCircuit : Bool = false
    var CheckedCircuit : Bool = false
    var firstLocation : CLLocation!
    var positionFirstLocation : String = ""
    var direction : String = ""
    var speed : Double = 0.0
    var diff : Int = 0
    var oldLocation: CLLocation!
    var coordinates = [CLLocationCoordinate2D]()
    var coordinatesSaved = [CLLocationCoordinate2D]()
    
    var timerStart = Timer()
    var startTimeInterval = TimeInterval()
    var elapsedTime = TimeInterval()
    var arrayTimesLaps = [TimeInterval]()
    var minValue = 8400000.0
    var lap : Int = 0
    var loopLaps : Int = 0
    //
    var miniTripsCounter: Int = 0
    var startDate: Double = 0.0
    var endDate: Double = -1.0
    var startLocation: realmTripLocation?
    var endLocation: realmTripLocation?
    var distance: Double = 0.0
    var speedArray = [Double]()
    var routeArray = [NSDictionary]()
    var motionArray = [NSDictionary]()
    var bestLap: Double = 0.0
    var numberBestLap: Int = 0
    var numberLaps: Int = 0
    var isCircuit : Bool = false
    var isMotionAvailable: Bool = true
    var tripLapsTimeArray = [TimeInterval]()
    
    var currentMaxRotationX: Double = 0.0
    var currentMaxRotationY: Double = 0.0
    var currentMaxRotationZ: Double = 0.0
    
    var Yaw : Double = 0.0
    var Picth : Double = 0.0
    var Roll : Double = 0.0
    
    var currentAccelerationX : Double = 0.0
    var currentAccelerationY : Double = 0.0
    var currentAccelerationZ : Double = 0.0
    
    var accelerationMaxX : Double = 0.0
    var accelerationMaxY : Double = 0.0
    var accelerationMaxZ : Double = 0.0
    var accelerationMinX : Double = 0.0
    var accelerationMinY : Double = 0.0
    var accelerationMinZ : Double = 0.0
    
    
    func initValues(){
        LocationService.sharedInstance.delegate = self
        LocationService.sharedInstance.cleanValuesInfo()
        LocationService.sharedInstance.startUpdatingLocation()
        
        MotionServiceManager.sharedInstance.delegate = self
        MotionServiceManager.sharedInstance.initMotion()
    }
    
    func cleanValues(){
    
        miniTripsCounter = 0
        startDate = 0.0
        startLocation = realmTripLocation()
        speedArray = [Double]()
        routeArray = [NSDictionary]()
        motionArray = [NSDictionary]()
        oldLocation = nil
        bestLap = 0.0
        numberBestLap = 0
        numberLaps = 0
        isCircuit = false
        isMotionAvailable = true
        tripLapsTimeArray = [TimeInterval]()
    }
    
    
    public func startTrip(){
        startTimer()
        cleanValues()
        enableTrip = true
        LocationService.sharedInstance.cleanValuesInfo()
        startLocation?.latitud = (LocationService.sharedInstance.currentLocation?.coordinate.latitude)!
        startLocation?.longitud = (LocationService.sharedInstance.currentLocation?.coordinate.longitude)!
        startLocation?.timestamp = NSDate.timeIntervalSinceReferenceDate
    }
    
    public func stopTrip(){
        createSnapshotStats(oldLocation , isFirst:false , isLast:true)
        timerStart.invalidate()
        coordinatesSaved = [CLLocationCoordinate2D]()
        oldLocation = nil
        enableTrip = false
    }
    
    func startTimer(){
        startTimeInterval = NSDate.timeIntervalSinceReferenceDate
        timerStart = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            
            let currentTime = NSDate.timeIntervalSinceReferenceDate
            self.elapsedTime = currentTime - self.startTimeInterval
            
            let value = helper_1.valueTimeInString(time:self.elapsedTime)
            let dict : NSDictionary = [ "currentLap" : value ]
            self.updatenotifyTimeCurrentLap(dict)
        })
    }
    
    func temporalDisable(){
        let deadlineTime = DispatchTime.now() + .seconds(10)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.CheckedCircuit = false
        }
    }
    
    private func checkCircuitNear(currentLocation: CLLocation){
        if firstLocation != nil{
            let diff = currentLocation.distance(from: firstLocation)
            
            if diff < 3 && positionFirstLocation == direction  && !CheckedCircuit{
                
                self.CheckedCircuit = true
                self.isCircuit = true
                self.temporalDisable()
                arrayTimesLaps.append(self.elapsedTime)
                self.elapsedTime = TimeInterval()
                self.startTimer()
                
                loopLaps = arrayTimesLaps.count
                
                if loopLaps > 0 {
                    for var i in 0 ..< arrayTimesLaps.count {
                        if minValue > arrayTimesLaps[i] {
                            minValue = arrayTimesLaps[i]
                            lap = i + 1
                        }
                    }
                }
                
                let dict : NSDictionary = [
                                            "isCircuit" : NSNumber.init(value: true) ,
                                            "bestTimeLap" : helper_1.valueTimeInString(time:minValue) ,
                                            "bestLap" : NSNumber.init(value: lap) ,
                                            "timesLaps" : arrayTimesLaps
                ]
                
                self.updatenotifyIsCircuit(dict)
            }
        }
    }
    
    //MARK: CoreTrips
    
    func createSnapshotStats(_ currentLocation: CLLocation , isFirst:Bool , isLast:Bool){
        
        // Start Location
        if startLocation?.latitud == nil && startLocation?.longitud == nil{
            startLocation?.latitud = firstLocation.coordinate.latitude
            startLocation?.longitud = firstLocation.coordinate.longitude
            startLocation?.timestamp = NSDate.timeIntervalSinceReferenceDate
        }
        
        // Speed
        
        NSLog("******* SPEED  %i" , speedArray.count)
        
        
        speedArray.append(speed)
        // Route
        let longitud: Double = currentLocation.coordinate.latitude
        let latitud: Double = currentLocation.coordinate.longitude
        let distanceToLastPoint: Double = oldLocation.distance(from: currentLocation)
        let timestamp: Double = NSDate.timeIntervalSinceReferenceDate
        let dictRoute : NSDictionary = [
                                            "longitud" : longitud,
                                            "latitud" : latitud,
                                            "distanceToLastPoint" : distanceToLastPoint,
                                            "timestamp" : timestamp
                                        ]
        routeArray.append(dictRoute)
        //Motion
        let dictMotion : NSDictionary = [
                                            "currentAccelerationX": currentAccelerationX,
                                            "currentAccelerationY": currentAccelerationY,
                                            "currentAccelerationZ": currentAccelerationZ,
                                            "accelerationMaxX": accelerationMaxX,
                                            "accelerationMaxY": accelerationMaxY,
                                            "accelerationMaxZ": accelerationMaxZ,
                                            "accelerationMinX": accelerationMinX,
                                            "accelerationMinY": accelerationMinY,
                                            "accelerationMinZ": accelerationMinZ,
                                            "currentMaxRotationX": currentMaxRotationX,
                                            "currentMaxRotationY": currentMaxRotationY,
                                            "currentMaxRotationZ": currentMaxRotationZ,
                                            "Yaw": Yaw,
                                            "Picth": Picth,
                                            "Roll" : Roll
                                        ]
        motionArray.append(dictMotion)
        //Circuit Values
        if isCircuit{
            bestLap = minValue
            numberBestLap = lap
            numberLaps = loopLaps
            tripLapsTimeArray = arrayTimesLaps
        }
        
        let endLocation = realmTripLocation()
        endLocation.latitud = currentLocation.coordinate.latitude
        endLocation.longitud = currentLocation.coordinate.longitude
        endLocation.timestamp = NSDate.timeIntervalSinceReferenceDate
        
        if speedArray.count > 20 || isFirst || isLast{
            
            dbRealmManager.shared.saveValuesTrip(isFirst: isFirst, isLast: isLast, startLocation: startLocation!, endLocation: endLocation , speedArray: speedArray, routeArray: routeArray, motionArray: motionArray, isCircuit: isCircuit, bestLap: bestLap ,numberBestLap:numberBestLap , numberLaps:numberLaps , tripLapsTimeArray:tripLapsTimeArray)
            
            speedArray = [Double]()
            routeArray = [NSDictionary]()
            motionArray = [NSDictionary]()
        }
    }
    
    ///MARK: Motion Manager
    func tracingMotionAcceleration(_ acceleration: NSDictionary) {
        currentAccelerationX = acceleration.object(forKey: "currentAccelerationX") as! Double
        currentAccelerationY = acceleration.object(forKey: "currentAccelerationY") as! Double
        currentAccelerationZ = acceleration.object(forKey: "currentAccelerationZ") as! Double
        accelerationMaxX = acceleration.object(forKey: "accelerationMaxX") as! Double
        accelerationMaxY = acceleration.object(forKey: "accelerationMaxY") as! Double
        accelerationMaxZ = acceleration.object(forKey: "accelerationMaxZ") as! Double
        accelerationMinX = acceleration.object(forKey: "accelerationMinX") as! Double
        accelerationMinY = acceleration.object(forKey: "accelerationMinY") as! Double
        accelerationMinZ = acceleration.object(forKey: "accelerationMinZ") as! Double
    }
    
    func tracingMotionRotation(_ rotation: NSDictionary) {
        currentMaxRotationX = rotation.object(forKey: "currentMaxRotationX") as! Double
        currentMaxRotationY = rotation.object(forKey: "currentMaxRotationY") as! Double
        currentMaxRotationZ = rotation.object(forKey: "currentMaxRotationZ") as! Double
        Yaw = rotation.object(forKey: "Yaw") as! Double
        Picth = rotation.object(forKey: "Picth") as! Double
        Roll = rotation.object(forKey: "Roll") as! Double
    }
    
    ///MARK: Location Manager
    func tracingLocation(_ currentLocation: CLLocation) {
        if enableTrip{
            if oldLocation != nil{
                let diff = currentLocation.distance(from: oldLocation)
                coordinates.append(currentLocation.coordinate)
                
                if enableCheckCircuit{
                    checkCircuitNear(currentLocation:currentLocation)
                }
                if diff > 10{
                    enableCheckCircuit = true
                    createSnapshotStats(currentLocation , isFirst:false , isLast:false)
                }
            }else{
                coordinatesSaved.append(currentLocation.coordinate)
                oldLocation = currentLocation
                firstLocation = currentLocation
                createSnapshotStats(currentLocation , isFirst:true , isLast:false)
            }
        }
        updatetracingLocationTrip(currentLocation)
    }
    
    func tracingLocationChangedInfo(_ infoLocation: NSDictionary) {
        
        if positionFirstLocation.isEqual("") && enableTrip{
            positionFirstLocation = infoLocation.object(forKey:"direction") as! String
        }
        
        direction = infoLocation.object(forKey:"direction") as! String
        
        if infoLocation.object(forKey:"speed") != nil{
            if let value = Int((infoLocation.object(forKey:"speed") as? String)!){
                speed = Double(value)
            }
        }
        
        self.updatetracingLocationChangedInfoTrip(infoLocation)
    }
    
    //MARK: Private function
    
    fileprivate func updatetracingLocationTrip(_ currentLocation: CLLocation){
        guard let delegate = self.delegate else{
            return
        }
        delegate.tracingLocationTrip(currentLocation)
    }
    
    fileprivate func updatetracingLocationChangedInfoTrip(_ infoLocation: NSDictionary){
        guard let delegate = self.delegate else{
            return
        }
        delegate.tracingLocationChangedInfoTrip(infoLocation)
    }

    fileprivate func updatenotifyIsCircuit(_ data: NSDictionary){
        guard let delegate = self.delegate else{
            return
        }
        delegate.notifyIsCircuit(data)
    }
    
    fileprivate func updatenotifyTimeCurrentLap(_ data: NSDictionary){
        guard let delegate = self.delegate else{
            return
        }
        delegate.notifyTimeCurrentLap(data)
    }
    
    
}
