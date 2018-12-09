//
//  ProfileTable.swift
//  babyhaha
//
//  Created by Duo Zheng on 11/30/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit

class ProfileTable: UITableView, UITableViewDelegate, UITableViewDataSource {

    override func awakeFromNib() {
        self.delegate = self
        self.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BundleCell", for: indexPath) as! BundleCell
        
        return cell
    }
}
