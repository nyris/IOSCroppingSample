//
//  Created by MOSTEFAOUI Anas on 31/12/2017.
//  Copyright © 2017 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK

class CameraController : UIViewController {
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    var isLoading:Bool = false
    
    lazy var cameraManager: CameraManager = {
        let configuration = CameraConfiguration(metadata: [], captureMode: .none, sessionPresent: SessionPreset.res1920x1080)
        return CameraManager(configuration: configuration)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // subscribe to notification after camera is setup and displayed, to avoid some matrix error
        // see : http://stackoverflow.com/questions/20734929/avcapturesession-barcode-scan
        self.subscribeToApplicationEventNotifications()
    }
    // MARK: - setup
    func setupCamera() {
        let configuration = CameraConfiguration(metadata: [],
                                                captureMode: .none,
                                                sessionPresent: SessionPreset.res1920x1080,
                                                allowBarcodeScan:false)
        self.cameraManager =  CameraManager(configuration: configuration)
        self.cameraManager.authorizationDelegate  = self
        
        if self.cameraManager.permission != .authorized {
            self.cameraManager.updatePermission()
        } else {
            self.cameraManager.setup()
            self.cameraManager.display(on: self.cameraView)
        }
        
    }
    
    // MARK: - UI Actions
    @IBAction func captureAction(_ sender: UIButton) {
        
        guard self.cameraManager.permission == .authorized else {
            self.cameraManager.updatePermission()
            return
        }
        // saving the picture may take some time, lock to avoid spam the button
        sender.isEnabled =  false
        
        // this method will save, rotate, and resize the picture
        // this actions should be available as parameters
        self.isLoading = true
        self.cameraManager.takePicture { [weak self] image, originalImage in
            self?.processCapturedImage(image: image, originalImage: originalImage)
        }
    }
    
    /// Process captured image, this should be implemented by the child class
    /// This method should reset the capture button to its original enabled state to be able to capture other pictures
    /// - Parameter image: image captured by the camera
    func processCapturedImage(image:UIImage?, originalImage:UIImage?) {
        fatalError("processCapturedImage is not implemented in child class")
    }
}

/// Notifications extension
extension CameraController {
    
    // MARK: - notifications subscriptions
    func subscribeToApplicationEventNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(applicationSuspended), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationActivated), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationSuspended), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationSuspended), name: UIApplication.willTerminateNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationActivated), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - notifications callback
    /// resume capture session when the application is active/forground
    @objc func applicationActivated() {
        if self.cameraManager.isRunning == false && self.isLoading == false {
            self.cameraManager.start()
        }
    }
    
    /// properly shutdown/stop camera service when the app is in the background or will be terminated
    @objc func applicationSuspended() {
        
        if self.cameraManager.isRunning == true {
            self.cameraManager.stop()
        }
    }
}

extension CameraController : CameraAuthorizationDelegate {
    func didChangeAuthorization(cameraManager: CameraManager, authorization: SessionSetupResult) {
        switch authorization {
        case .authorized:
            if self.cameraManager.isRunning == false {
                self.cameraManager.setup()
            }
            self.cameraManager.display(on: self.cameraView)
        default:
            let message = "Capture your product"
            self.showError(message: message, okActionLogic: { (_) in
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    fatalError("Invalid application setting url")
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        }
    }
}
