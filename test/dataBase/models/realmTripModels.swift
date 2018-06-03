//
//  SCPRealmTripRoute.swift
//  SeatCarPlay
//
//  Created by Albert Arredondo on 09/03/2017.
//  Copyright © 2017 Martínez Gonzalez, Daniel (EXTERN: Opentrends). All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class realmTripLocation : Object {
    
    @objc dynamic var longitud: Double = 0.0
    @objc dynamic var latitud: Double = 0.0
    @objc dynamic var distanceToLastPoint: Double = 0.0
    @objc dynamic var intervalToLastPoint: Double = 0.0
    @objc dynamic var timestamp: Double = 0.0
    
    func convertToCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }
    
}

class realmTripMotion : Object {
    
    @objc dynamic var currentMaxRotationX: Double = 0.0
    @objc dynamic var currentMaxRotationY: Double = 0.0
    @objc dynamic var currentMaxRotationZ: Double = 0.0
    @objc dynamic var Yaw : Double = 0.0
    @objc dynamic var Picth : Double = 0.0
    @objc dynamic var Roll : Double = 0.0
    @objc dynamic var currentAccelerationX : Double = 0.0
    @objc dynamic var currentAccelerationY : Double = 0.0
    @objc dynamic var currentAccelerationZ : Double = 0.0
    @objc dynamic var accelerationMaxX : Double = 0.0
    @objc dynamic var accelerationMaxY : Double = 0.0
    @objc dynamic var accelerationMaxZ : Double = 0.0
    @objc dynamic var accelerationMinX : Double = 0.0
    @objc dynamic var accelerationMinY : Double = 0.0
    @objc dynamic var accelerationMinZ : Double = 0.0
}

class realmTripSpeed : Object {
    @objc dynamic var speed: Double = 0.0
}

class realmTripTimeLap : Object {
    @objc dynamic var duration: Double = 0.0
}



