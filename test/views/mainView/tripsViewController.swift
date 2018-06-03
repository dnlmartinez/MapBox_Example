//
//  tripsViewController.swift
//  test
//
//  Created by daniel martinez gonzalez on 30/3/18.
//

import UIKit
import RealmSwift
import CollectionViewSlantedLayout

class tripsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: CollectionViewSlantedLayout!
    
    var tripsArray = Array<realmTrip>()
    let reuseIdentifier = "customViewCell"
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripsArray = Array(dbRealmManager.shared.getAllTrips())
        collectionViewLayout.isFirstCellExcluded = false
        collectionViewLayout.isLastCellExcluded = false
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.lineSpacing = 20.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    @IBAction func pressBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension tripsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomCollectionCell
        
        let date = Date.init(timeIntervalSinceReferenceDate: tripsArray[indexPath.row].startDate)
        
        tripsArray[indexPath.row].getStringStartLocation { (place) in
            if place != nil{
                let street : String = (place?.name)!
                let city : String = (place?.locality)!
                let country : String = (place?.country)!
                cell.startLocationAdress.text = street + "," + city + "(" + country + ")"
            }else{
                cell.startLocationAdress.text = "Loading location..."
            }
        }
        tripsArray[indexPath.row].getStringEndLocation { (place) in
            if place != nil{
                let street : String = (place?.name)!
                let city : String = (place?.locality)!
                let country : String = (place?.country)!
                cell.endLocationAdress.text = street + "," + city + "(" + country + ")"
            }else{
                cell.endLocationAdress.text = "Loading location..."
            }
        }
        
        cell.image = UIImage.init(named:"\(Int(arc4random_uniform(10) + 1))")!
        cell.labelTime.text = helper_1.valueTimeInString(time:TimeInterval(tripsArray[indexPath.row].totalTripTime())) + " min."
        cell.labelDay.text = "\(date.dayMedium)"
        cell.labelMonth.text = "\(date.monthMedium)"
        
        
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1.0
        cell.clipsToBounds = true
        
        if let layout = collectionView.collectionViewLayout as? CollectionViewSlantedLayout {
            cell.contentView.transform = CGAffineTransform(rotationAngle: layout.slantingAngle)
        }
        return cell
    }
}

extension tripsViewController: CollectionViewDelegateSlantedLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let trip : realmTrip = tripsArray[indexPath.row]
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "tripDetailViewController") as! tripDetailViewController
        newViewController.trip = trip
        
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: CollectionViewSlantedLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGFloat {
        return collectionViewLayout.scrollDirection == .vertical ? 275 : 325
    }
}


extension tripsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = self.collectionView else {return}
        guard let visibleCells = collectionView.visibleCells as? [CustomCollectionCell] else {return}
        for parallaxCell in visibleCells {
            let yOffset = ((collectionView.contentOffset.y - parallaxCell.frame.origin.y) / parallaxCell.imageHeight) * yOffsetSpeed
            let xOffset = ((collectionView.contentOffset.x - parallaxCell.frame.origin.x) / parallaxCell.imageWidth) * xOffsetSpeed
            parallaxCell.offset(CGPoint(x: xOffset,y :yOffset))
        }
    }
}

