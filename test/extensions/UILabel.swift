//
//  UILabel.swift
//  test
//
//  Created by daniel martinez gonzalez on 3/4/18.
//

import UIKit
import Foundation
import QuartzCore

extension UILabel{
    
    func addShining(color: UIColor, radius: CGFloat, opacity: Float){
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.layer.shouldRasterize = true
            self.layer.shadowColor = color.cgColor
            self.layer.shadowRadius = radius
            self.layer.shadowOpacity = opacity
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.layer.masksToBounds = false
            self.layer.shouldRasterize = true
        }, completion: nil)
    }
    
}






