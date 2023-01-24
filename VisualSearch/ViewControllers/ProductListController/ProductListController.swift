//
//  ProductListController.swift
//  VisualSearch
//
//  Created by Anas Mostefaoui on 24/01/2023.
//  Copyright © 2023 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK

final class ProductListController : UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource:ProductListDataSource!
    var result:[Offer] = []
    var resultTitle:String {
        return "\(result.count) results"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollection()
        self.title = resultTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    func setupCollection() {
        let productCelLNib = UINib(nibName: "ProductCell", bundle: Bundle.main)
        collectionView.register(productCelLNib, forCellWithReuseIdentifier: ProductCell.identifier)
        dataSource = ProductListDataSource(items:result, collection: collectionView)
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        dataSource.onItemSelected = { [weak self] item, indexPath in
            guard item.getAvailableURL() != nil else {
                self?.showError(message: "Product link is not available")
                return
            }
        }
    }
}

extension ProductListController : DataTransferProtocol {
    
    typealias Data = Offer
    
    func transfer(data: [Offer]) {
        for offer in data {
            self.result.append(offer)
        }
    }
    
}
