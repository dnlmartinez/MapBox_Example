//
//  RealmManager.swift
//  SeatCarPlay
//
//  Created by Jesus Bellon on 22/2/17.
//  Copyright © 2017 Martínez Gonzalez, Daniel (EXTERN: Opentrends). All rights reserved.
//

import UIKit
import RealmSwift


class dbRealmManager: NSObject {
    
    static let shared = dbRealmManager()

    struct realmConstants {
        static let realmDBName      : String = "realmData"
        static let realmDBExtension : String = ".realm"
    }
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        return dateFormatter
    }()
    
    override init() {
        super.init()
    }
    
    var actualTripID : Int = 0
    
    //MARK: DATABASE METHODS
    
    func getRealmDatabase() -> Realm {
        let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.path
        let url = NSURL(fileURLWithPath: path)
        
        let config = Realm.Configuration(
            fileURL: url.appendingPathComponent(realmConstants.realmDBName + realmConstants.realmDBExtension),
            readOnly: false
        )
        
        do{
            return try Realm(configuration: config)
        }
        catch{
            return try! Realm()
        }
    }
    
    //MARK: TRIPS METHODS
    
    
    func saveValuesTrip(isFirst:Bool , isLast:Bool , startLocation:realmTripLocation , endLocation:realmTripLocation , speedArray:[Double] , routeArray:[NSDictionary] , motionArray:[NSDictionary] , isCircuit:Bool , bestLap: Double ,numberBestLap:Int , numberLaps:Int , tripLapsTimeArray:[Double]){
        
        let realm = self.getRealmDatabase()
        var mytrip = realmTrip()
        
        try! realm.write {
        if isFirst{
            //First miniTrip
            actualTripID = Int(NSDate.timeIntervalSinceReferenceDate)
            mytrip.startLocation = startLocation
            mytrip.startDate = NSDate.timeIntervalSinceReferenceDate
            mytrip.id = actualTripID
        }else{
            //Mini trips
            mytrip = getLastTrip()!
            
            if isLast{
                //End miniTrip
                mytrip.endDate = NSDate.timeIntervalSinceReferenceDate
                mytrip.endLocation = endLocation
            }
        }
        
        for var i in 0..<speedArray.count{
            let tripSpeed = realmTripSpeed()
            let speed = speedArray[i]
            tripSpeed.speed = speed
            mytrip.tripSpeed.append(tripSpeed)
        }
        
        for var i in 0..<routeArray.count{
            let tripRoute = realmTripLocation()
            let dic : NSDictionary = routeArray[i] as! NSDictionary
            
            tripRoute.latitud = dic.object(forKey: "latitud") as! Double
            tripRoute.longitud = dic.object(forKey: "longitud") as! Double
            tripRoute.timestamp = dic.object(forKey: "timestamp") as! Double
            tripRoute.distanceToLastPoint = dic.object(forKey: "distanceToLastPoint") as! Double
            mytrip.tripRoute.append(tripRoute)
        }
        
        for var i in 0..<motionArray.count{
            let tripMotion = realmTripMotion()
            let dic : NSDictionary = motionArray[i] as! NSDictionary
            
            tripMotion.currentMaxRotationX = dic.object(forKey: "currentMaxRotationX") as! Double
            tripMotion.currentMaxRotationY = dic.object(forKey: "currentMaxRotationY") as! Double
            tripMotion.currentMaxRotationZ = dic.object(forKey: "currentMaxRotationZ") as! Double
            tripMotion.Yaw = dic.object(forKey: "Yaw") as! Double
            tripMotion.Picth = dic.object(forKey: "Picth") as! Double
            tripMotion.Roll = dic.object(forKey: "Roll") as! Double
            tripMotion.currentAccelerationX = dic.object(forKey: "currentAccelerationX") as! Double
            tripMotion.currentAccelerationY = dic.object(forKey: "currentAccelerationY") as! Double
            tripMotion.currentAccelerationZ = dic.object(forKey: "currentAccelerationZ") as! Double
            tripMotion.accelerationMaxX = dic.object(forKey: "accelerationMaxX") as! Double
            tripMotion.accelerationMaxY = dic.object(forKey: "accelerationMaxY") as! Double
            tripMotion.accelerationMaxZ = dic.object(forKey: "accelerationMaxZ") as! Double
            tripMotion.accelerationMinX = dic.object(forKey: "accelerationMinX") as! Double
            tripMotion.accelerationMinY = dic.object(forKey: "accelerationMinY") as! Double
            tripMotion.accelerationMinZ = dic.object(forKey: "accelerationMinZ") as! Double
            mytrip.tripMotion.append(tripMotion)
            mytrip.isMotionAvailable = true
        }
        
        if isCircuit{
            //Circuit Values
            mytrip.isCircuit = true
            mytrip.bestLap = bestLap
            mytrip.numberBestLap = numberBestLap
            mytrip.numberLaps = numberLaps
            //let tripLapsTime = realmTripTimeLap()
        }
        
        mytrip.miniTripsCounter = mytrip.miniTripsCounter + 1
        realm.add(mytrip , update: true)
        }
    }
    
    
    func getTripsAverageDrivingTime() -> Double {
        let realm = getRealmDatabase()
        let trips = realm.objects(realmTrip.self)
        
        var totalDrivingTime: Double = 0.0
        for trip in trips {
            let drivingTime: Double = trip.totalTripTime()
            totalDrivingTime = totalDrivingTime + drivingTime
        }
        return totalDrivingTime / Double(trips.count)
    }
    
    func getTripsAverageSpeed() -> Double {
        let realm = getRealmDatabase()
        let trips = realm.objects(realmTrip.self)

        var totalAverageSpeed: Double = 0.0
        for trip in trips {
            totalAverageSpeed = totalAverageSpeed + trip.tripSpeedAverage()
        }
        return totalAverageSpeed / Double(trips.count)
    }
    
    func getAllTrips() -> Results<realmTrip> {
        let realm = getRealmDatabase()
        let trips = realm.objects(realmTrip.self).sorted(byKeyPath: "startDate", ascending: false)
        return trips
    }
    
    func getLastTrip() -> realmTrip? {
        let realm = getRealmDatabase()
        let trips = realm.objects(realmTrip.self)
        
        if let trip = trips.filter("id == %i", actualTripID).first{
            return trip
        }
        return nil
    }
    
    func deleteTrip(trip: realmTrip) {
        let realm = getRealmDatabase()
        try! realm.write {
            realm.delete(trip.tripRoute)
            realm.delete(trip)
        }
    }
    
}
