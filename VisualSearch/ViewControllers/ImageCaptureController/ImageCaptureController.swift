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
    private var visualSearchService:VisualSearchService!
    override var isLoading:Bool {
        didSet(oldValue) {
            self.updateLoadingState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualSearchService = VisualSearchService(controller: self)
        isLoading = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resumeCamera()
    }
    
    func updateLoadingState() {
        DispatchQueue.main.async {
            self.darkView.isHidden = !self.isLoading
            self.captureButton.isEnabled = !self.isLoading
            self.isLoading == true ?
                self.activityIndicator.startAnimating() :
                self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - UI Actions
    override func processCapturedImage(image: UIImage?, originalImage:UIImage?) {

        self.cameraManager.stop()
        guard let validImage = image else {
            self.showError(message: "Invalid Image")
            return
        }
        
        self.isLoading = true
        self.visualSearchService.getOffersWithBoxes(image: validImage) { (offers, boxes, error) in
            DispatchQueue.main.async {
                self.isLoading = false
                self.displayObjectProposal(image: validImage, offers: offers, boxes: boxes, error: error)
            }
        }
    }
    
    func displayObjectProposal(image:UIImage, offers:[Offer], boxes:[ExtractedObject], error:Error?) {
        self.captureButton.isEnabled = true
        guard !boxes.isEmpty else {
            self.showError(message: "No offers found")
            self.cameraManager.start()
            return
        }
        
        let storyboard = UIStoryboard(name: "CropController", bundle: Bundle.main)
        let controller = storyboard.instantiateInitialViewController() as! CropController
        controller.transfer(data: (image:image, offers:offers, boxes:boxes))
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
