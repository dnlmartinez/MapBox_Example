//
//  Copyright © 2016 SEAT S.A. All rights reserved.
//
// This file is part of SeatCarPlay.
//
// Unauthorized reproduction, copying, or modification, of this file, via
// any medium is strictly prohibited.
//
// This code is Proprietary and Confidential.
//
// All the 3rd parties libraries included in the project are regulated by
// their own licenses.
//
//

import Foundation
import UIKit

extension UIColor
{
    
    convenience init( hex: String)
    {
        var hex = hex
        var alpha: String = "#FF"
        let hexLength = hex.characters.count
        
        if !(hexLength == 7 || hexLength == 9)
        {
            self.init(white: 0, alpha: 1)
            return
        }
        
        if hexLength == 9
        {
            
            alpha = "#" + hex.substring(to: hex.index(hex.startIndex , offsetBy: 3)).substring(from: hex.index(hex.startIndex , offsetBy: 1))
            hex = "#" + hex.substring(from: hex.index(hex.startIndex , offsetBy: 3))
            
            //alpha = "#" + hex.substringToIndex(hex.startIndex.advancedBy(3)).substringFromIndex(hex.startIndex.advancedBy(1))
            //hex = "#" + hex.substringFromIndex(hex.startIndex.advancedBy(3))
        }
        else if hexLength == 7
        {
            hex = "#" + hex.substring(from: hex.index(hex.startIndex , offsetBy: 1))
            
            //hex = "#" + hex.substringFromIndex(hex.startIndex.advancedBy(1))
        }
        
        var rgb: UInt32 = 0
        let s: Scanner = Scanner(string: hex)
        s.scanLocation = 1
        s.scanHexInt32(&rgb)
        
        
        var alphaValue: UInt32 = 0
        let sAlpha: Scanner = Scanner(string: alpha)
        sAlpha.scanLocation = 1
        sAlpha.scanHexInt32(&alphaValue)
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alphaValue) / 255.0 )
    }
    
    convenience init( hex: String, alpha: CGFloat)
    {
        var hex = hex
        let hexLength = hex.characters.count
        if !(hexLength == 7)
        {
            self.init(white: 0, alpha: 1)
            return
        }
        
        if hexLength == 7
        {
            hex = "#" + hex.substring(from: hex.index(hex.startIndex , offsetBy: 1))
            //hex = "#" + hex.substringFromIndex(hex.startIndex.advancedBy(1))
        }
        
        var rgb: UInt32 = 0
        let s: Scanner = Scanner(string: hex)
        s.scanLocation = 1
        s.scanHexInt32(&rgb)
        
        // Creating the UIColor from hex int
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alpha)
        
    }
    
    
    static func transparent() -> UIColor
    {
        return UIColor(white: 0, alpha: 0)
    }
    
    static func tableSeparatorColor() -> UIColor
    {
        return UIColor.white.withAlphaComponent(0.2)
    }
    
    static func whiteAlpha() -> UIColor
    {
        return UIColor.white.withAlphaComponent(0.2)
    }
    
    static func whiteAlpha(alpha: CGFloat) -> UIColor
    {
        return UIColor.white.withAlphaComponent(alpha)
    }
    
    
    static func CPbackgroundColor() -> UIColor
    {
        return UIColor.init(hex: "#181818")
    }
    
    
}
