//
//  ImageCaptureCoordinator.swift
//  EverybagExpress
//
//  Created by MOSTEFAOUI Anas on 28/06/2017.
//  Copyright © 2017 everybag. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import NyrisSDK

final class ImageCaptureCoordinator {
    
    let controller:UIViewController
    let matchingService = ImageMatchingService()
    let extractionService = ProductExtractionService()
    let dispatchGroup = DispatchGroup()
    
    var offerList:[Offer] = []
    var extractedObject:[ExtractedObject] = []
    
    init(controller:UIViewController) {
        self.controller = controller
        
        let language = matchingService.acceptLanguage
        matchingService.acceptLanguage = language == "DE" ? "DE" : "EN"
    }
    
    func getOffersWithBoxes(image:UIImage,
                            isSemanticSearch:Bool = false,
                            completion:@escaping ( _ offerList:[Offer], _ objects:[ExtractedObject], _ error:Error?) -> Void) {
        dispatchGroup.enter()
        
        extractionService.getExtractObjects(from: image) { [weak self] (objects, error) in
            self?.handleExtractionResponse(objects: objects, error: error)
        }
        
        dispatchGroup.enter()
        self.getOffers(image: image, isSemanticSearch:isSemanticSearch) { (_, _) in
            self.dispatchGroup.leave()
        }
    
        dispatchGroup.notify(queue: .main) { [weak self] in
            // offer
            completion(self?.offerList ?? [], self?.extractedObject ?? [], nil)
        }
    }
    
    func getOffers(
        image:UIImage,
        isSemanticSearch:Bool = false,
        completion:@escaping ( _ offerList:[Offer], _ error:Error?) -> Void) {
        matchingService.getSimilarProducts(
            image: image,
            isSemanticSearch: isSemanticSearch) { [weak self] products, error in
                self?.handleResponse(similarProducts: products?.products, error: error, completion: completion)
        }
        
    }

    func handleExtractionResponse(objects:[ExtractedObject]?, error:Error?) {
        // save the boxes
        self.extractedObject = objects ?? []
        dispatchGroup.leave()
    }
    
    func handleResponse(
        similarProducts:[Offer]?,
        error:Error?,
        completion:@escaping ( _ offerList:[Offer], _ error:Error?) -> Void) {

        guard error == nil else {
            controller.showError(title:"Error",
                           message:"Something went wrong with our service. It’s our fault, not yours. Please try again.")
            completion([], error)
            return
        }
        self.offerList = similarProducts ?? []
        completion(self.offerList, nil)
    }
}
