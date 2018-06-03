//
//  helper_1.swift
//  test
//
//  Created by daniel martinez gonzalez on 26/3/18.
//

import Foundation
import UIKit

class helper_1{
    
    static func getString(key: String) -> String?
    {
        let preferences = UserDefaults.standard
        return preferences.string(forKey: key)
        
    }
    
    static func redirectConsoleLogToDocumentFolder() {
        var paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory: NSString = paths[0] as! NSString
        
        let name: String = "console_\(NSDate().timeIntervalSince1970).log"
        let logPath: NSString = documentsDirectory.appendingPathComponent(name) as NSString
        let cstr = (logPath as NSString).utf8String
        
        freopen(cstr, "a+", stderr)
    }
    
    static func waterEffect(delegate: UIViewController) ->CATransition{
        let animation : CATransition = CATransition()
        animation.delegate = delegate as! CAAnimationDelegate
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.type = "rippleEffect"
        animation.fillMode = kCAFillModeRemoved
        animation.endProgress = 0.99
        animation.isRemovedOnCompletion = true
        return animation
    }
    
    static func valueTimeInString(time:TimeInterval)->String{
        var time = time
        let minutes = UInt8(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        let seconds = UInt8(time)
        time -= TimeInterval(seconds)
        let fraction = UInt8(time * 100)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        return "\(strMinutes):\(strSeconds):\(strFraction)"
    }
}
