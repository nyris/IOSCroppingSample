//
//  ProductCell.swift
//  VisualSearch
//
//  Created by Anas Mostefaoui on 24/01/2023.
//  Copyright © 2023 Nyris. All rights reserved.
//

import UIKit
import Kingfisher
import NyrisSDK

final class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    
    public static let identifier = "ProductCell"
    var item:Offer?
    
    override func prepareForReuse() {
        nameLable.text = ""
        priceLable.text = ""
        imageView.image = nil
        item = nil
    }
    
    func bind(item:Offer) {
        self.item = item
        
        let price = item.price ?? ""
        priceLable.text = "\(price)".uppercased()
        let merchant = item.brand != nil ? item.brand! + "\n" : ""
        nameLable.text = "\(merchant)\(item.title ?? "")"

        if let link = item.images?.first, let url = URL(string:link) {
            self.imageView.kf.setImage(with: url,
                                       placeholder: UIImage(systemName: "photo"),
                                              options: nil,
                                              progressBlock: nil,
                                              completionHandler: nil)
        } else {
            self.imageView.image = UIImage(systemName: "photo")
        }
    }
}
