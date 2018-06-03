//
//  MotionServiceManager.swift
//  test
//
//  Created by daniel martinez gonzalez on 25/3/18.
//

import UIKit
import CoreMotion

protocol MotionServiceDelegate{
    func tracingMotionAcceleration(_ acceleration: NSDictionary)
    func tracingMotionRotation(_ rotation: NSDictionary)
}

class MotionServiceManager: NSObject
{
    static let sharedInstance: MotionServiceManager =
    {
        let instance = MotionServiceManager()
        return instance
    }()

    var delegate: MotionServiceDelegate?
    
    let motionManager = CMMotionManager()
    
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
    
    override init(){
        super.init()
    }
    
    func initMotion(){
        
        if motionManager.isGyroAvailable && motionManager.isAccelerometerAvailable{
            motionManager.deviceMotionUpdateInterval = 0.2;
            motionManager.startDeviceMotionUpdates()
            motionManager.gyroUpdateInterval = 0.2
            
            motionManager.startGyroUpdates(to: OperationQueue.current! , withHandler: { (gyro , error) in
                self.outputRotationData(rotation: gyro!.rotationRate)
            })
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (acceleration, error) in
                self.outputAccelerationData(acceleration:acceleration!.acceleration)
            })
            
        } else {
            // alert message
            NSLog("No hay Motion!!!")
        }
        
    }
    
    func outputAccelerationData(acceleration:CMAcceleration){
        
        currentAccelerationX = acceleration.x
        currentAccelerationY = acceleration.y
        currentAccelerationZ = acceleration.z
        
        if acceleration.x > accelerationMaxX { accelerationMaxX = acceleration.x }
        if acceleration.y > accelerationMaxY { accelerationMaxY = acceleration.y }
        if acceleration.z > accelerationMaxZ { accelerationMaxZ = acceleration.z }
        if acceleration.x < accelerationMinX { accelerationMinX = acceleration.x }
        if acceleration.y < accelerationMinY { accelerationMinY = acceleration.y }
        if acceleration.z < accelerationMinZ { accelerationMinZ = acceleration.z }
        
        
        let dict : NSDictionary = [
            "currentAccelerationX" : currentAccelerationX,
            "currentAccelerationY" : currentAccelerationY,
            "currentAccelerationZ" : currentAccelerationZ,
            "accelerationMaxX" : accelerationMaxX,
            "accelerationMaxY" : accelerationMaxY,
            "accelerationMaxZ" : accelerationMaxZ,
            "accelerationMinX" : accelerationMinX,
            "accelerationMinY" : accelerationMinY,
            "accelerationMinZ" : accelerationMinZ
        ]
        updateMotionAcceleration(dict)
    }
    
    func outputRotationData(rotation:CMRotationRate)
    {
        
        if fabs(rotation.x) > fabs(currentMaxRotationX){ currentMaxRotationX = rotation.x }
        if fabs(rotation.y) > fabs(currentMaxRotationY){ currentMaxRotationY = rotation.y }
        if fabs(rotation.z) > fabs(currentMaxRotationZ){ currentMaxRotationZ = rotation.z }
        
        var attitude = CMAttitude()
        var motion = CMDeviceMotion()
        
        if motionManager.deviceMotion != nil{
            motion = motionManager.deviceMotion!
            attitude = motion.attitude
            
            Yaw = attitude.yaw
            Picth = attitude.pitch
            Roll = attitude.roll
        }
        
        let dict : NSDictionary = [
            "currentMaxRotationX" : currentMaxRotationX,
            "currentMaxRotationY" : currentMaxRotationY,
            "currentMaxRotationZ" : currentMaxRotationZ,
            "Yaw" : Yaw,
            "Picth" : Picth,
            "Roll" : Roll
        ]
        
        updateMotionRotation(dict)
    }

    //MARK: Private function
    
    fileprivate func updateMotionAcceleration(_ acceleration: NSDictionary){
        guard let delegate = self.delegate else{
            return
        }
        delegate.tracingMotionAcceleration(acceleration)
    }
    
    fileprivate func updateMotionRotation(_ rotation: NSDictionary){
        guard let delegate = self.delegate else{
            return
        }
        delegate.tracingMotionRotation(rotation)
    }
    
}
