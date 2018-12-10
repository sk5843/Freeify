//
//  BundlesCollection.swift
//  babyhaha
//
//  Created by Duo Zheng on 11/30/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit

class BundlesCollection: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var imagesArray = ["clothing1", "clothing2", "clothing3"]
    var imagesTitle = ["Zara", "Gucci", "Fendi"]
    override func awakeFromNib() {
        self.delegate = self
        self.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BundleCell", for: indexPath) as? BundleCell
        cell?.categoryBundle.image = UIImage(named: imagesArray[indexPath.row])
        cell?.categoryBundleLabel.setTitle(imagesTitle[indexPath.row], for: .normal)
        return cell!
    }
    
}


