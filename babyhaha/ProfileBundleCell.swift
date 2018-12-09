//
//  ProfileBundleCell.swift
//  babyhaha
//
//  Created by Duo Zheng on 11/30/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import Firebase


class ProfileBundleCell: UICollectionViewCell {
    var isAnimate: Bool! = true
   
    
    @IBOutlet weak var coverImg: UIImageView!
    
    @IBOutlet weak var boxTitle: UILabel!
    
    
    @IBOutlet weak var removeBtn: UIButton!
    
    @IBAction func removeBtnPressed(_ sender: UIButton) {
        
        let hitPoint = sender.convert(CGPoint.zero, to: boxCollectionViewgl)
        let hitIndex = boxCollectionViewgl!.indexPathForItem(at: hitPoint)
            
        //remove the box and refresh the collection view
        var titleToRemove = Boxesarr[(hitIndex?.row)!].title
        Boxesarr.remove(at: (hitIndex?.row)!)
        Database.database().reference().child("Boxes").child(titleToRemove).removeValue()
        boxCollectionViewgl!.reloadData()
        
    }
    
    func startAnimate() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.05
        shakeAnimation.repeatCount = 4
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.2
        shakeAnimation.repeatCount = 99999
        
        let startAngle: Float = (-2) * 3.14159/180
        let stopAngle = -startAngle
        
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.timeOffset = 290 * drand48()
        
        let layer: CALayer = self.layer
        layer.add(shakeAnimation, forKey:"animate")
        removeBtn.isHidden = false
        isAnimate = true
    }
    func stopAnimate() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "animate")
        self.removeBtn.isHidden = true
        isAnimate = false
    }
    
}
