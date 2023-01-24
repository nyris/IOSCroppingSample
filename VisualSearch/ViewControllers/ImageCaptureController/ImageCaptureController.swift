//
//  ImageCaptureController.swift
//  EverybagExpress
//
//  Created by MOSTEFAOUI Anas on 27/06/2017.
//  Copyright © 2017 everybag. All rights reserved.
//

import UIKit
import NyrisSDK

final class ImageCaptureController: CameraController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var darkView: UIView!

    
    private var coordinator:ImageCaptureCoordinator!
    
    override var isLoading:Bool {
        didSet(oldValue) {
            self.updateLoadingState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = ImageCaptureCoordinator(controller: self)
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resumeCamera()
    }
    
    func setupUI() {
        isLoading = false
    }
    
    func updateLoadingState() {
        DispatchQueue.main.async {
            self.darkView.isHidden = self.isLoading == false
            self.captureButton.isEnabled = self.isLoading == false
            self.isLoading == true ?
                self.activityIndicator.startAnimating() :
                self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - UI Actions
    override func processCapturedImage(image: UIImage?, originalImage:UIImage?) {

        self.cameraManager.stop()
        guard let validImage = image, let validOriginalImage = originalImage else {
            self.showError(message: "Invalid Image")
            return
        }
 
        self.coordinator.getOffersWithBoxes(image: validImage) { (offers, boxes, error) in
            self.isLoading = false
            DispatchQueue.main.async {
                self.processedImageFlow(image: validImage,
                                        originalImage: validOriginalImage,
                                        offers: offers,
                                        boxes: boxes,
                                        error: error)
            }
        }
    }
    
    func processedImageFlow(image:UIImage, originalImage:UIImage, offers:[Offer], boxes:[ExtractedObject], error:Error?) {
        self.captureButton.isEnabled = true
        
        let storyboard = UIStoryboard(name: "CropController", bundle: Bundle.main)
        let controller = storyboard.instantiateInitialViewController() as! CropController
        controller.transfer(data: (image:image, original:originalImage, offers:offers, boxes:boxes))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleInvalidImageData() {
        self.showError(message: "Invalid image")
        self.resumeCamera()
    }
    
    fileprivate func resumeCamera() {
        if self.cameraManager.isRunning == false {
            self.cameraManager.start()
        }
    }
}
