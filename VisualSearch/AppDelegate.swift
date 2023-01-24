//
//  AppDelegate.swift
//  VisualSearch
//
//  Created by MOSTEFAOUIM on 24/01/2023.
//

import UIKit
import NyrisSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NyrisClient.instance.setup(clientID: "")
        
        return true
    }
}

