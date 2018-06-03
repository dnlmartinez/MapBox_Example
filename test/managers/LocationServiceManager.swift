//
//  LocationManager.swift
//  WarehouseCode
//
//  Created by daniel martinez gonzalez on 11/9/17.
//  Copyright © 2017 daniel martinez gonzalez. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate{
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
    var last : CLLocation?
    
    var delegate: LocationServiceDelegate?
    
    var lowSpeedValue : String = "0 Km/h"
    var highSpeedValue : String = "0 Km/h"
    var totalDist : String = "0 Metros"
    
    var magneticH : String = "N"
    var totalDistAlways : Double = 0.0
    var votesAvg : Int = 0
    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance:Double = 0
    var arrayMPH: [Int] = [Int]()
    var arrayKPH: [Int] = [Int]()
    
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
        
        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = kCLHeadingFilterNone
            locationManager.startUpdatingHeading()
            locationManager.headingOrientation = .landscapeRight
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
        votesAvg = 0
        traveledDistance = 0.0
        arrayMPH = [Int]()
        arrayKPH = [Int]()
    }
    
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.last else
        {
            return
        }
        
        if (location.horizontalAccuracy > 0) {
            
            if lastLocation != nil{
            let distancechanged = locations.last!.distance(from: lastLocation)
            let sinceLastUpdate = (location.timestamp).timeIntervalSince(lastLocation.timestamp)
            let calculatedSpeed = distancechanged / sinceLastUpdate
                
            updateLocationInfo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, speed:calculatedSpeed , direction: location.course)
            }
            
        }
        
        if lastLocation != nil {
            
            let oldtraveledDistance = traveledDistance
            traveledDistance += lastLocation.distance(from: locations.last!)
            let diff = traveledDistance - oldtraveledDistance

            totalDistAlways += diff
            
                if traveledDistance < 1000 {
                    let tdMeter = traveledDistance
                    totalDist = String.localizedStringWithFormat("%.0f Metros", tdMeter)
                    
                } else if traveledDistance > 1000 {
                    
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
        
        if (speedToKPH > 0) {
            arrayKPH.append(Int(speedToKPH))
            lowSpeedValue =  String.localizedStringWithFormat("%i Km/h", arrayKPH.min()!)
            highSpeedValue = String.localizedStringWithFormat("%i Km/h", arrayKPH.max()!)
            avgSpeed()
            
        } else {
            speedToKPH = 0.0
        }
    
        let Speed = String.localizedStringWithFormat("%i", Int(speedToKPH))
        
        let info : NSDictionary = [
                                    "distance" : totalDist,
                                    "speed" : Speed,
                                    "lowSpeed" : lowSpeedValue,
                                    "hightSpeed" : highSpeedValue,
                                    "speedAvg" : votesAvg,
                                    "direction" : magneticH,
                                    "totalDistance" : totalDistAlways
                                    ]
        
        notifyLocationChangedInfo(info)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        
        let value = Int(heading.magneticHeading.binade)
        
        if value > 0 && value < 20 {
            magneticH = "N"
        }
        if value > 70 && value < 110 {
            magneticH = "E"
        }
        if value > 160 && value < 200 {
            magneticH = "S"
        }
        if value > 250 && value < 290 {
            magneticH = "W"
        }
        if value > 20 && value < 70  {
            magneticH = "NE"
        }
        if value > 110 && value < 160 {
            magneticH = "SE"
        }
        if value > 200 && value < 250  {
            magneticH = "SW"
        }
        if value > 290 {
            magneticH = "NW"
        }
    }
    
    
    func avgSpeed(){
        let votes:[Int] = arrayKPH
        votesAvg = votes.reduce(0, +) / votes.count
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

