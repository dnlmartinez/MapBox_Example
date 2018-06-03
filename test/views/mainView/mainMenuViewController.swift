//
//  mainMenuViewController.swift
//  test
//
//  Created by daniel martinez gonzalez on 27/3/18.
//

import UIKit
import AVFoundation


class mainMenuViewController: UIViewController {

    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var constrainHeightContentView: NSLayoutConstraint!
    
    @IBOutlet weak var viewRace: UIView!
    @IBOutlet weak var viewTrips: UIView!
    @IBOutlet weak var viewStats: UIView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var viewLastCard: UIView!
    @IBOutlet weak var viewSetting: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewRace.alpha = 0.0
        self.viewTrips.alpha = 0.0
        self.viewStats.alpha = 0.0
        self.viewMessage.alpha = 0.0
        self.viewLastCard.alpha = 0.0
        //playVideo()
        self.updateLayout()
        self.animateMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let screenSize = UIScreen.main.bounds
        self.constrainHeightContentView.constant = screenSize.height
        //self.layoutShadows()
        self.layoutCornering()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func layoutShadows(){
        viewRace.addShadow(location: .bottom, color: .white, opacity: 0.5, radius: 5.0)
        viewTrips.addShadow(location: .bottom, color: .white, opacity: 0.5, radius: 5.0)
        viewStats.addShadow(location: .bottom, color: .white, opacity: 0.5, radius: 5.0)
        viewMessage.addShadow(location: .bottom, color: .white, opacity: 0.5, radius: 5.0)
        viewSetting.addShadow(location: .bottom, color: .white, opacity: 0.5, radius: 5.0)
    }
    
    private func layoutCornering(){
        viewRace.addCornering(value: 5.0 , borderColor: .white , borderWith: 0.2)
        viewTrips.addCornering(value: 5.0 , borderColor: .white , borderWith: 0.2)
        viewStats.addCornering(value: 5.0 , borderColor: .white , borderWith: 0.2)
        viewMessage.addCornering(value: 5.0 , borderColor: .white , borderWith: 0.2)
        viewSetting.addCornering(value: 5.0 , borderColor: .white , borderWith: 0.2)
    }
    
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "video", ofType:"MOV") else {
            debugPrint("resource not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.isMuted = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.viewVideo.layer.addSublayer(playerLayer)
        player.play()
        let viewBlack : UIView = UIView.init(frame: self.viewVideo.frame)
        viewBlack.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.viewVideo.addSubview(viewBlack)
    }
    
    private func updateLayout(){
        self.contentView.bringSubview(toFront:viewRace)
        self.contentView.bringSubview(toFront:viewTrips)
        self.contentView.bringSubview(toFront:viewStats)
        self.contentView.bringSubview(toFront:viewMessage)
        self.contentView.bringSubview(toFront:viewLastCard)
        self.contentView.bringSubview(toFront:viewSetting)
    }
    
    private func animateMenu(){
        UIView.animate(withDuration: 0.0, animations: {
            self.viewRace.transform = CGAffineTransform.init(translationX: 1000, y: 0)
            self.viewTrips.transform = CGAffineTransform.init(translationX: 1000, y: 0)
            self.viewStats.transform = CGAffineTransform.init(translationX: 1000, y: 0)
            self.viewMessage.transform = CGAffineTransform.init(translationX: 1000, y: 0)
            self.viewLastCard.transform = CGAffineTransform.init(translationX: 1000, y: 0)
        }) { (succes) in
            UIView.animate(withDuration: 1.5, animations: {
                self.viewRace.transform = CGAffineTransform.identity
                self.viewTrips.transform = CGAffineTransform.identity
                self.viewStats.transform = CGAffineTransform.identity
                self.viewMessage.transform = CGAffineTransform.identity
                self.viewLastCard.transform = CGAffineTransform.identity
                self.viewRace.alpha = 1.0
                self.viewTrips.alpha = 1.0
                self.viewStats.alpha = 1.0
                self.viewMessage.alpha = 1.0
                self.viewLastCard.alpha = 1.0
            }, completion: { (success) in
              NSLog("END ANIMATION!!")
            })
        }
    }
    
    ///MARK: Buttons Menu Action's
    
    @IBAction func pressRaceContextAction(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "raceViewController") as! raceViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    @IBAction func pressTripContextAction(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "tripsViewController") as! tripsViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    @IBAction func pressSettingContextAction(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "settingViewController") as! settingViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    

}
