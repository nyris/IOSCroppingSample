//
//  SceneDelegate.swift
//  VisualSearch
//
//  Created by MOSTEFAOUIM on 24/01/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let navigationController = UINavigationController()
        let storyboard = UIStoryboard(name: "ImageCaptureController", bundle: Bundle.main)
        let captureController = storyboard.instantiateViewController(withIdentifier: "ImageCaptureController") as! ImageCaptureController
        navigationController.pushViewController(captureController, animated: false)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        
    }
}

