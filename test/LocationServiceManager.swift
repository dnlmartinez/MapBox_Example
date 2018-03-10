//
//  LocationManager.swift
//  WarehouseCode
//
//  Created by daniel martinez gonzalez on 11/9/17.
//  Copyright © 2017 daniel martinez gonzalez. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate
{
    func tracingLocation(_ currentLocation: CLLocation)
    func tracingLocationChangedInfo ( _ infoLocation: NSDictionary)
}


class LocationService: NSObject, CLLocationManagerDelegate
{
    static let sharedInstance: LocationService =
    {
        let instance = LocationService()
        return instance
    }()
    
    var locationManager: CLLocationManager?
    
    var currentLocation: CLLocation?
    var lastLocationRequest : CLLocation?
    
    var delegate: LocationServiceDelegate?
    
    var lowSpeedValue : String = "0 Km/h"
    var highSpeedValue : String = "0 Km/h"
    var totalDist : String = "0 Metros"
    var totalDistAlways : String = "0 Metros"
    
    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance:Double = 0
    var arrayMPH: [Double]! = []
    var arrayKPH: [Double]! = []
    
    override init()
    {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else
        {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined
        {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.delegate = self
    }
    
    
    func statusAuthorization() -> Bool
    {
        if CLLocationManager.authorizationStatus() == .authorizedAlways
        {
            return true
        }
        else if CLLocationManager.authorizationStatus() == .notDetermined
        {
            return false
        }
        else if CLLocationManager.authorizationStatus() == .denied
        {
            return false
        }
        else
        {
            return false
        }
    }
    
    func getCurrentLocation()-> CLLocation
    {
        if currentLocation == nil
        {
            self.locationManager?.startUpdatingLocation()
            return CLLocation()
            
        }
        else
        {
            self.locationManager?.startUpdatingLocation()
            return currentLocation!
        }
    }
    
    
    func startUpdatingLocation()
    {
        self.locationManager?.startUpdatingLocation()
    }
    
    
    func stopUpdatingLocation()
    {
        self.locationManager?.stopUpdatingLocation()
    }
    
    
    func cleanValuesInfo() {
        lowSpeedValue = "0 Km/h"
        highSpeedValue  = "0 Km/h"
        totalDist  = "0 Metros"
    }
    
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.last else
        {
            return
        }
        
        if (location.horizontalAccuracy > 0) {
            updateLocationInfo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, speed: location.speed, direction: location.course)
        }
        if lastLocation != nil {
            traveledDistance += lastLocation.distance(from: locations.last!)
                if traveledDistance < 1609 {
                    let tdMeter = traveledDistance
                    totalDist = String.localizedStringWithFormat("%.0f Metros", tdMeter)
                } else if traveledDistance > 1609 {
                    let tdKm = traveledDistance / 1000
                    totalDist = String.localizedStringWithFormat("%0.1f Kilometros", tdKm)
                }
        }
        
        lastLocation = locations.last
        currentLocation = location
        updateLocation(location)
    }
    
    
    func updateLocationInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees, speed: CLLocationSpeed, direction: CLLocationDirection) {
        
        var speedToKPH = (speed * 3.6)
        
        
        let val = ((direction / 22.5) + 0.5);
        var arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        let dir = arr[Int(val / 16)]
        
        if (speedToKPH > 0) {
            NSLog("speedToKPH  %.0f km/h", speedToKPH)
            arrayKPH.append(speedToKPH)
            lowSpeedValue =  "\(arrayKPH.min)"
            highSpeedValue = "\(arrayKPH.max)"
            avgSpeed()
            
        } else {
            speedToKPH = 0.0
        }
    
        let info : NSDictionary = [
                                    "distance:" : totalDist,
                                    "speed:" : speedToKPH,
                                    "lowSpeed:" : lowSpeedValue,
                                    "hightSpeed:" : highSpeedValue,
                                    "yaw:" : dir
                                    ]
        
        notifyLocationChangedInfo(info)
    }
    
    
    func avgSpeed(){
        let votes:[Double] = arrayKPH
        let votesAvg = votes.reduce(0, +) / Double(votes.count)
        NSLog("votesAvg  %.0f", votesAvg)
    }
    
    
    private func addTotalDistance(value: String){
        
        var numberTotal : NSNumber!
        var number : NSNumber!
        
        
        if totalDistAlways.contains("Kilometros"){
            totalDistAlways.replacingOccurrences(of: " Kilometros", with: "")
        
            numberTotal =
            
        }else if totalDistAlways.contains("Metros"){

            totalDistAlways.replacingOccurrences(of: " Metros", with: "")
            
            numberTotal =
        }
        
        
        
        
        ////
     
        if value.contains("Kilometros"){
        
            value.replacingOccurrences(of: " Kilometros", with: "")
            
            
            totalDistAlways = ""
        }else if value.contains("Metros"){
            
            value.replacingOccurrences(of: " Metros", with: "")
            
            
            totalDistAlways = ""
        }
        
    }
    
    //MARK: Private function
    
    fileprivate func notifyLocationChangedInfo(_ infoLocation : NSDictionary)
    {
        guard let delegate = self.delegate else
        {
            return
        }
        delegate.tracingLocationChangedInfo(infoLocation)
    }
    
    fileprivate func updateLocation(_ currentLocation: CLLocation)
    {
        guard let delegate = self.delegate else
        {
            return
        }
        delegate.tracingLocation(currentLocation)
    }
    
}

