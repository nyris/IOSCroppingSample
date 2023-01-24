//
//  ProductListDataSource.swift
//  VisualSearch
//
//  Created by Anas Mostefaoui on 24/01/2023.
//  Copyright © 2023 Nyris. All rights reserved.
//

import Foundation
import UIKit
import NyrisSDK

typealias OnItemSelected = (_ item:Offer, _ index:IndexPath) -> Void

final class ProductListDataSource: NSObject, UICollectionViewDataSource {
    
    weak var collection:UICollectionView?
    var items:[Offer]
    var onItemSelected:OnItemSelected?
    
    init(items:[Offer], collection:UICollectionView) {
        self.items = items
        self.collection = collection
    }
    
    func update(items:[Offer]) {
        self.items = items
        self.collection?.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let productCell = cell as? ProductCell else {
            fatalError("Invalid cell type")
        }
        let item = self.items[indexPath.row]
        productCell.bind(item: item)
    }
    
}

extension ProductListDataSource : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("collection view Not using flow layout")
        }
        
        let width = collectionView.bounds.size.width -
            (layout.sectionInset.left + layout.sectionInset.right)
        let height = (width * 343) / 296
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.items.isEmpty == false, indexPath.row < self.items.count else {
            print("row out of range")
            return
        }
        let item = self.items[indexPath.row]
        self.onItemSelected?(item, indexPath)
    }
    
}
