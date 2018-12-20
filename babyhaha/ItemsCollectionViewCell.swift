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
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

protocol ItemsCellDelegate{
    
    func itemsRemBtnPressed(index: Int)
}

class ItemsCollectionViewCell: UICollectionViewCell {
    
    var isAnimate: Bool! = true
    var boxIndexCurrent:Int?
    var delegate: ItemsViewController!
    
    
    @IBAction func itemsRemBtnPressed(_ sender: UIButton) {
        delegate.itemsRemBtnPressed(index: sender.tag)
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

