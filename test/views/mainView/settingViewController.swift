//
//  settingViewController.swift
//  test
//
//  Created by daniel martinez gonzalez on 8/4/18.
//

import UIKit
import SpotifyLogin


class settingViewController: UIViewController {
    
    @IBOutlet weak var viewLoginBT: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(observerNotification), name: .SpotifyLoginSuccessful, object: nil)
        
        let button = SpotifyLoginButton(viewController: self, scopes: [.streaming, .userLibraryRead])
        
        self.viewLoginBT.addSubview(button)
    }
    
    
    //SpotifyLogin.shared.logout()
    
    override func viewDidAppear(_ animated: Bool) {
        
        SpotifyLogin.shared.getAccessToken { (accessToken, error) in
            if error != nil {
                // User is not logged in, show log in flow.
                NSLog("\n -AccesToken:  \(accessToken)    \n -Name: \(SpotifyLogin.shared.username)")
            }
        }
        
    }
    
    @objc func observerNotification(notification: NSNotification){
        
        NSLog("Llega Notificacion \(notification.userInfo)")
        
        SpotifyLogin.shared.getAccessToken { (accessToken, error) in
            if error != nil {
                // User is not logged in, show log in flow.
                NSLog("\n -AccesToken:  \(accessToken)    \n -Name: \(SpotifyLogin.shared.username)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func pressBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
