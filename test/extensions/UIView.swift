//
//  UIView.swift
//  test
//
//  Created by daniel martinez gonzalez on 3/4/18.
//

import Foundation
import UIKit

enum VerticalLocation: String {
    case bottom
    case top
}

extension UIView {
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: 10), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -10), color: color, opacity: opacity, radius: radius)
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    
    func addCornering(value: CGFloat , borderColor: UIColor = .black , borderWith: CGFloat){
        self.layer.cornerRadius = value
        self.layer.borderWidth = borderWith
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
}
