//
//  CropController.swift
//  VisualSearch
//
//  Created by Anas Mostefaoui on 24/01/2023.
//  Copyright © 2023 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK

final class CropController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var selectionLable: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var darkView: UIView!
    
    private let cropViewTag = -123
    private var resizedImage:UIImage!
    private var visualSearchService:VisualSearchService!
    private var boundingBoxes:[CropOverlay] = []
    private var boxes:[ExtractedObject] = []
    private var isLoading:Bool = false {
        didSet(oldValue) {
            self.updateLoadingState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualSearchService = VisualSearchService(controller: self)
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
    
    @IBAction func onCrop(_ sender: Any) {
        
        self.isLoading = false
        let selectedBox = self.boundingBoxes.filter({ $0.isSelected == true }).first
        
        guard let cropBox = selectedBox else {
            self.showError(message: "Please Select a box")
            return
        }

        let baseFrame = CGRect(x: 0, y: 0, width: self.resizedImage.size.width, height: self.resizedImage.size.height)
        let projectedRect = cropBox.frame.projectOn(projectionFrame: baseFrame, from: imageView.frame)
        let cropedImage = ImageHelper.crop(image: self.resizedImage, croppingRect: projectedRect)
        
        guard let selectedImge = cropedImage else {
            self.showError(message: "The croped image is invalid, please retry again with different size")
            return
        }
        
        self.isLoading = true
        visualSearchService.getOffers(image: selectedImge) { (offerList, error) in
            
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
            return
        }
        let storyboard = UIStoryboard(name: "ProductListController", bundle: Bundle.main)
        let controller = storyboard.instantiateInitialViewController() as! ProductListController
        controller.transfer(data: offers)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension CropController: DataTransferProtocol {
    typealias Data = (image:UIImage, offers:[Offer], boxes:[ExtractedObject])
    
    func transfer(data: Data) {
        self.boxes = data.boxes
        self.resizedImage = data.image
    }
}

extension CropController {
    public func displayBoundingBoxes() {
        self.boundingBoxes.removeAll()
        self.boxes = self.boxes.sorted(by: { $0.confidence < $1.confidence })
        
        guard let mostConfidentBox = self.boxes.first else {
            return
        }
        
        for box in self.boxes where box.extractionFromFrame != nil {
            let normalizedRect = box.region
                .normalized(sourceFrame: box.extractionFromFrame!)
                .toCGRect()
            let crop = self.generateBox(boxRect: normalizedRect, outergap: 0)
            self.boundingBoxes.append(crop)
            
            if mostConfidentBox == box {
                crop.isSelected = true
            }
        }

        self.updateBoxesLayout()
    }
    
    func generateBox(boxRect:CGRect, outergap:CGFloat) -> CropOverlay {
        let cropView = CropOverlay()
        cropView.tag = cropViewTag
        cropView.translatesAutoresizingMaskIntoConstraints = false
        cropView.minimumSize = CGSize(width: 100, height: 100)
        cropView.onSelected = { object in
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

        cropView.frame = destination
        cropView.alpha = 0.8
        
        return cropView
    }
    
    func updateBoxesLayout() {
        view.subviews
            .filter({$0.tag == cropViewTag})
            .forEach( { $0.removeFromSuperview() })
        self.boundingBoxes.forEach({ view.addSubview($0) })
        view.bringSubviewToFront(selectionButton)
    }
}
