//
//  ItemsCollectionViewCell.swift
//  babyhaha
//
//  Created by Sai~ on 12/2/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import ImagePicker
import Firebase

class ItemsCollectionViewCell: UICollectionViewCell {
    
    var isAnimate: Bool! = true
    @IBAction func itemsRemBtnPressed(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: itCView)
        let hitIndex = itCView!.indexPathForItem(at: hitPoint)
        
        //remove the image and refresh the collection view
        Boxesarr[boxIndexCurrent!].items.remove(at: (hitIndex?.row)!)
        //Database.database().reference().child("Boxes").child(titleToRemove).removeValue()
        itCView!.reloadData()
    }
    
    @IBOutlet weak var itemsRemBtn: UIButton!
    @IBOutlet weak var itemImageView: UIImageView!
    
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
        self.itemsRemBtn.isHidden = false
        isAnimate = true
    }
    func stopAnimate() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "animate")
        self.itemsRemBtn.isHidden = true
        isAnimate = false
    }
}

