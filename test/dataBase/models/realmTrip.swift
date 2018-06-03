//
//  RLM_TRIP.swift
//  SeatCarPlay
//
//  Created by Jesus Bellon on 23/2/17.
//  Copyright © 2017 Martínez Gonzalez, Daniel (EXTERN: Opentrends). All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import CoreLocation


class realmTrip : Object {
    
    @objc dynamic var isMotionAvailable: Bool = true
    
    @objc dynamic var id: Int = 0
    @objc dynamic var miniTripsCounter: Int = 0
    
    @objc dynamic var startDate: Double = 0.0
    @objc dynamic var endDate: Double = -1.0
    @objc dynamic var startLocation: realmTripLocation?
    @objc dynamic var endLocation: realmTripLocation?
    @objc dynamic var distance: Double = 0.0
    
    let tripSpeed = List<realmTripSpeed>()
    let tripRoute = List<realmTripLocation>()
    let tripMotion = List<realmTripMotion>()
    
    @objc dynamic var isCircuit : Bool = false
    @objc dynamic var bestLap: Double = 0.0
    @objc dynamic var numberBestLap: Int = 0
    @objc dynamic var numberLaps: Int = 0
    
    let tripLapsTime = List<realmTripTimeLap>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func isOngoing() -> Bool{
        let dateComponents = Calendar.current.dateComponents([Calendar.Component.minute], from: Date(timeIntervalSince1970: endDate) , to: Date(timeIntervalSince1970: Date().timeIntervalSince1970))
        
        if let minutes = dateComponents.minute{
            return minutes <= 60
        }
        else{
            return true
        }
    }
    
    func totalTripTime() -> Double{
        var diffTime = abs(endDate - startDate)
        
        if diffTime > 3599.0{
            diffTime = 3599.0
        }
        
        return diffTime
    }
    
    func maxSpeedValue() -> Double{
        var value : Double = 0.0
        for var i in 0 ..< Array(tripSpeed).count{
            if tripSpeed[i].speed > value{
                value = tripSpeed[i].speed
            }
        }
        return value
    }
    
    func minSpeedValue() -> Double{
        var value : Double = 250.0
        for var i in 0 ..< Array(tripSpeed).count{
            if tripSpeed[i].speed < value{
                value = tripSpeed[i].speed
            }
        }
        return value
    }
    
    func tripSpeedAverage() -> Double{
        var value : Double = 0.0
        for var i in 0 ..< Array(tripSpeed).count{
            value = value + tripSpeed[i].speed
        }
        value = value / Double(Array(tripSpeed).count)
        return value
    }
    
    
    func getStringStartLocation(completionHandler: @escaping (CLPlacemark?)-> Void){
        
        let geocoder = CLGeocoder()
        if startLocation?.latitud != nil && startLocation?.longitud != nil{
            let location : CLLocation = CLLocation(latitude: (startLocation?.latitud)!, longitude: (startLocation?.longitud)!)
            
            geocoder.reverseGeocodeLocation(location) { (place, error) in
                if error == nil{
                    completionHandler(place?[0])
                }else{
                    completionHandler(nil)
                }
            }
        }else{
            completionHandler(nil)
        }
    }
    
    func getStringEndLocation(completionHandler: @escaping (CLPlacemark?)-> Void){
        
        let geocoder = CLGeocoder()
        
        if endLocation?.latitud != nil && endLocation?.longitud != nil{
            let location : CLLocation = CLLocation(latitude: (endLocation?.latitud)!, longitude: (endLocation?.longitud)!)
            
            geocoder.reverseGeocodeLocation(location) { (place, error) in
                if error == nil{
                    completionHandler(place?[0])
                }else{
                    completionHandler(nil)
                }
            }
        }else{
            completionHandler(nil)
        }
    }

    func getRouteInLocationCoordinates() -> [CLLocationCoordinate2D]{
        
        var coordinates : [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        for var i in 0 ..< Array(tripRoute).count{
            if tripRoute[i].latitud != 0.0 && tripRoute[i].longitud != 0.0{
                let lat : Double = tripRoute[i].latitud
                let lng : Double = tripRoute[i].longitud
                let object : CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: lng , longitude: lat)
                coordinates.append(object)
            }
        }
        return coordinates
    }
    
}
