//
//  CustomCollectionCell.swift
//  test
//
//  Created by daniel martinez gonzalez on 30/3/18.
//

import Foundation
import UIKit

import CollectionViewSlantedLayout

let yOffsetSpeed: CGFloat = 150.0
let xOffsetSpeed: CGFloat = 100.0

class CustomCollectionCell: CollectionViewSlantedCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var viewInfo: UIView!
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var startLocationAdress: UILabel!
    @IBOutlet weak var endLocationAdress: UILabel!
    
    
    private var gradient = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let backgroundView = backgroundView {
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            gradient.locations = [0.0, 1.0]
            gradient.frame = backgroundView.bounds
            backgroundView.layer.addSublayer(gradient)
        }
        
        self.viewDate.addShadow(location: .bottom, color: .darkGray, opacity: 0.8 , radius: 6.0)
        self.viewDate.addCornering(value: 8.0 , borderColor: .black, borderWith: 0.5)
        
        UIView.animate(withDuration: 0.0) {
            self.viewDate.transform = CGAffineTransform.init(rotationAngle: -0.18)
            self.viewInfo.transform = CGAffineTransform.init(rotationAngle: -0.18)
            self.viewTime.transform = CGAffineTransform.init(rotationAngle: -0.18)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let backgroundView = backgroundView {
            gradient.frame = backgroundView.bounds
        }
    }
    
    var image: UIImage = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    
    var imageHeight: CGFloat {
        return (imageView?.image?.size.height) ?? 0.0
    }
    
    var imageWidth: CGFloat {
        return (imageView?.image?.size.width) ?? 0.0
    }
    
    
    func offset(_ offset: CGPoint) {
        imageView.frame = self.imageView.bounds.offsetBy(dx: offset.x, dy: offset.y)
    }
}
