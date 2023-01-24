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
    
    var originalImage:UIImage!
    var resizedImage:UIImage!
    
    var coordinator:ImageCaptureCoordinator!
    var navigationHeaderHeight:CGFloat {
        return navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    var boundingBoxes:[CropOverlay] = []
    var offers:[Offer] = []
    var boxes:[ExtractedObject] = []
    private let cropViewTag = -123
    
    var didNavigateToResult:Bool = false
    var isSelectionState = false {
        didSet {
            isSelectionState ? self.setSelectionState() : self.setNavigationState()
        }
    }
    
    
    var isLoading:Bool = false {
        didSet(oldValue) {
            self.updateLoadingState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        coordinator = ImageCaptureCoordinator(controller: self)
        if self.didNavigateToResult {
            isSelectionState = true
        } else {
            isSelectionState = false
        }
        
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
    
    func setNavigationState() {
    
        DispatchQueue.main.async {
            self.selectionButton.isEnabled = false
            self.boundingBoxes.first?.isSelected = true
            self.boundingBoxes.first?.isMovable = false
            self.boundingBoxes.first?.isResizable = false
        }
        
        guard didNavigateToResult == false else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.goToResult()
        }
    }
    
    @IBAction func selectionAction(_ sender: Any) {
        self.isLoading = true
        // get selected box
        let selectedBox = self.boundingBoxes.filter {
            $0.isSelected == true
        }.first
        
        guard let cropBox = selectedBox else {
            self.isLoading = false
            self.showError(message: "Please Select a box")
            return
        }

        // if processed and no offer show error
        let baseFrame = CGRect(origin: .zero, size: self.originalImage.size)
        let projectedRect = cropBox.frame.projectOn(projectionFrame: baseFrame, from: imageView.frame)
        let cropedImage = ImageHelper.crop(image: self.originalImage, croppingRect: projectedRect)
        let boox = self.boxes.first!
        let crop = ImageHelper.crop(from: self.imageView,
                                    extractedObject: boox)
        // cropped Image should be 512 at least
        guard let selectedImge = cropedImage else {
            self.showError(message: "The croped image is invalid, please retry again with different size")
            self.isLoading = false
            return
        }
        
        coordinator.getOffers(image: selectedImge) { (offerList, error) in
            
            self.isLoading = true
            guard error == nil else {
                self.showError(message: error?.localizedDescription ?? "Something went wrong with our service. It’s our fault, not yours. Please try again.")
                return
            }
            
            self.offers = offerList
            DispatchQueue.main.async {
                self.goToResult()
            }
        }
    }
    
    func goToResult() {
        
        self.isLoading = false
        if self.didNavigateToResult {
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


        self.didNavigateToResult = true
    }
}

extension CropController: DataTransferProtocol {
    typealias Data = (image:UIImage, original:UIImage, offers:[Offer], boxes:[ExtractedObject])
    
    func transfer(data: Data) {
        self.offers = data.offers
        self.boxes = data.boxes
        self.originalImage = data.original
        self.resizedImage = data.image
        
        self.isSelectionState = self.offers.isEmpty ? true : false
        
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
    
        // clear all boxes
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
            let crop = self.generateBox(boxRect: box.region.toCGRect(), outergap: 0)
            if mostConfidentBox! == box {
                confidentCrop = crop
            }
            self.boundingBoxes.append(crop)
        }
        
        confidentCrop?.isSelected = true

        // clear all boxes
        self.updateBoxesLayout()
    }
    
    func generateBox(boxRect:CGRect, outergap:CGFloat) -> CropOverlay {
        let cameraOverlay = CropOverlay(frame: boxRect)
        cameraOverlay.tag = cropViewTag
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        cameraOverlay.isSelected = false
        cameraOverlay.minimumSize = CGSize(width: 100, height: 100)
        cameraOverlay.onSelected = { object in
            _ = self.boundingBoxes.map { $0.isSelected = false }
            object.isSelected = true
        }
    
        let baseFrame = CGRect(origin: .zero, size: resizedImage.size)
        let scaledRectangle = ImageHelper.applyRectProjection(on: boxRect,
                                                    from: baseFrame,
                                                    to: imageView.frame,
                                                    padding: cameraOverlay.outterGap,
                                                    navigationHeaderHeight: 0)
        
        cameraOverlay.frame = scaledRectangle
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
    }
}
