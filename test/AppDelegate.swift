//
//  AppDelegate.swift
//  test
//
//  Created by daniel martinez gonzalez on 2/3/18.
//

import UIKit
import SpotifyLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let authView : UIViewController! = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let myDict: NSDictionary = NSDictionary(contentsOfFile: path!)!
        let url : URL =  URL.init(string:"loginsample://")!
        let clientID : String = myDict.object(forKey: "SP_ClientID") as! String
        let clientSecret : String = myDict.object(forKey: "SP_SecretClientID") as! String
        SpotifyLogin.shared.configure(clientID: "9b71c98d1f8d41e7b2c1fa74bdffaa4a", clientSecret: "0a796fc22fc04844953bcf158809e603", redirectURL: url)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { (error) in }
        return handled
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}


}

