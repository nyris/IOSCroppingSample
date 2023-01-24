//
//  CropController.swift
//  VisualSearch
//
//  Created by Anas Mostefaoui on 24/01/2023.
//  Copyright © 2023 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK

class CropController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var selectionLable: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var darkView: UIView!
    
    var resizedImage:UIImage!
    var coordinator:ImageCaptureCoordinator!
    var navigationHeaderHeight:CGFloat {
        return navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    var boundingBoxes:[CropOverlay] = []
    var boxes:[ExtractedObject] = []
    
    private let cropViewTag = -123
    var isSelectionState = false {
        didSet(newValue) {
            if newValue {
                self.setSelectionState()
            }
        }
    }
    
    
    var isLoading:Bool = false {
        didSet(oldValue) {
            self.updateLoadingState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = ImageCaptureCoordinator(controller: self)
        self.bind()
    }
    

    func bind() {
        self.imageView.image = self.resizedImage
        self.displayBoundingBoxes()
    }
    
    func updateLoadingState() {
        DispatchQueue.main.async {
            self.selectionButton.isEnabled = self.isLoading == false
            self.isLoading == true ?
                self.activityIndicator.startAnimating() :
                self.activityIndicator.stopAnimating()
        }
    }
    
    func setSelectionState() {
        DispatchQueue.main.async {
            self.selectionButton.isEnabled = true
            // if we are not in selection state
            // we are doing animation, so quickly display the box and make it none movable/resizable
            self.boundingBoxes.first?.isSelected = false
            self.boundingBoxes.first?.isMovable = true
            self.boundingBoxes.first?.isResizable = true
        }
    }
    
    @IBAction func selectionAction(_ sender: Any) {
        // get selected box
        let selectedBox = self.boundingBoxes.filter {
            $0.isSelected == true
        }.first
        
        guard let cropBox = selectedBox else {
            self.isLoading = false
            self.showError(message: "Please Select a box")
            return
        }

        let baseFrame = CGRect(
            x: 0, y: 0,
            width: self.resizedImage.size.width,
            height: self.resizedImage.size.height
        )
        let projectedRect = cropBox.frame.projectOn(projectionFrame: baseFrame, from: imageView.frame)
        let cropedImage = ImageHelper.crop(image: self.resizedImage, croppingRect: projectedRect)
        
        guard let selectedImge = cropedImage else {
            self.showError(message: "The croped image is invalid, please retry again with different size")
            self.isLoading = false
            return
        }
        
        self.isLoading = true
        coordinator.getOffers(image: selectedImge) { (offerList, error) in
            
            self.isLoading = false
            guard error == nil else {
                self.showError(message: error?.localizedDescription ?? "Something went wrong with our service. It’s our fault, not yours. Please try again.")
                return
            }
            DispatchQueue.main.async {
                self.displayResults(offers:offerList)
            }
        }
    }
    
    func displayResults(offers:[Offer]) {
        guard offers.isEmpty == false else {
            self.showError(message: "No offers found")
            self.isSelectionState = true
            return
        }
        let storyboard = UIStoryboard(name: "ProductListController", bundle: Bundle.main)
        let controller = storyboard.instantiateInitialViewController() as! ProductListController
        controller.transfer(data: offers)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension CropController: DataTransferProtocol {
    typealias Data = (image:UIImage, original:UIImage, offers:[Offer], boxes:[ExtractedObject])
    
    func transfer(data: Data) {
        self.boxes = data.boxes
        self.resizedImage = data.image
        
        self.isSelectionState = self.boxes.isEmpty ? true : false
        
        // add at least one box if empty
        if self.boxes.isEmpty {
            let rect = CGRect(x: 0, y: 0,
                              width: resizedImage.size.width,
                              height: resizedImage.size.height)
            let centralBox = ExtractedObject.central(to: rect)
            self.boxes.append(centralBox)
        }
    }
}

extension CropController {
    public func displayBoundingBoxes() {
        self.boundingBoxes.removeAll()
        // get the heighest confidence object
        self.boxes = self.boxes.sorted(by: { (object1, object2) -> Bool in
            object1.confidence < object2.confidence
        })
        
        let mostConfidentBox = self.boxes.first
        guard mostConfidentBox != nil else {
            // invalid box
            return
        }
        
        // hold referance to the CropOverlay of the most confident bounding box
        var confidentCrop:CropOverlay?
        
        for box in self.boxes {
            let crop = self.generateBox(
                boxRect:box
                .region
                .normalized(sourceFrame: box.extractionFromFrame!).toCGRect(), outergap: 0)
            if mostConfidentBox! == box {
                confidentCrop = crop
            }
            self.boundingBoxes.append(crop)
        }
        
        confidentCrop?.isSelected = true
        self.updateBoxesLayout()
    }
    
    func generateBox(boxRect:CGRect, outergap:CGFloat) -> CropOverlay {
        let cameraOverlay = CropOverlay()
        cameraOverlay.tag = cropViewTag
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        cameraOverlay.minimumSize = CGSize(width: 100, height: 100)
        cameraOverlay.onSelected = { object in
            _ = self.boundingBoxes.map { $0.isSelected = false }
            object.isSelected = true
        }

        // since UIImageView is matching the main view of the controller
        // and we don't want to deal with constraints just for this
        // we use the view bounds
        let viewSize = self.view.bounds.size
        let destination = CGRect(
            x: viewSize.width * boxRect.origin.x,
            y: viewSize.height * boxRect.origin.y,
            width: viewSize.width * boxRect.size.width,
            height: viewSize.height * boxRect.size.height)

        cameraOverlay.frame = destination
        cameraOverlay.alpha = 0.8
        
        return cameraOverlay
    }
    
    func updateBoxesLayout() {
        // clear all boxes
        for subview in view.subviews where subview.tag == cropViewTag {
            subview.removeFromSuperview()
        }
        
        for box in self.boundingBoxes {
            view.addSubview(box)
        }
        
        view.bringSubviewToFront(selectionButton)
        view.layoutSubviews()
    }
}
