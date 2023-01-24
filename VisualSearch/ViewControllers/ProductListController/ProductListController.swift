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
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var resultLable: UILabel!
    
    var resultTitle:String {
        return "\(result.count) results"
    }
    
    var dataSource:ProductListDataSource!
    var result:[Offer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        self.applyDesign()

        setupCollection()
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
    
    func applyDesign() {
        resultLable.clipsToBounds = true
        resultLable.alpha = 1
        resultLable.text = resultTitle
    }
    
    @IBAction func backTaped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
