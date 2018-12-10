//
//  ItemsViewController.swift
//  babyhaha
//
//  Created by Sai~ on 12/2/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import ImagePicker

//Global variables
var itCView: ItemsCollectionView?
var boxIndexCurrent:Int?
class ItemsViewController: UIViewController {

    @IBOutlet weak var boxTitleLabel: UILabel!
    
    @IBOutlet weak var boxCategoryLabel: UILabel!
    
    @IBOutlet weak var boxDescription: UILabel!
    
    var boxTitle:String?
    var boxIndex:Int?
    var arr: [UIImage]?
    var longPressedEnabled = false

    @IBOutlet weak var ItemsCollectionVieww: ItemsCollectionView!

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var itemsAddbtn: UIButton!

    @IBAction func itemsAddPressed(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self as? ImagePickerDelegate
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        itCView = self.ItemsCollectionVieww
        boxIndexCurrent = self.boxIndex
        //adding longpress gesture over UICollectionView
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        ItemsCollectionVieww.addGestureRecognizer(longPressGesture)
        //Init view
        initializeView()
        
    }
    
    func initializeView(){
        for box in Boxesarr{
            if box.title == self.boxTitle{
                self.boxTitleLabel.text = box.title
                self.boxCategoryLabel.text = box.category
                self.boxDescription.text = box.description
            }
        }
    }
    
    @objc func longTap(_ gesture: UIGestureRecognizer){
        
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = ItemsCollectionVieww.indexPathForItem(at: gesture.location(in: ItemsCollectionVieww)) else {
                return
            }
            ItemsCollectionVieww.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            ItemsCollectionVieww.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            ItemsCollectionVieww.endInteractiveMovement()
            longPressedEnabled = true
            self.ItemsCollectionVieww.reloadData()
        default:
            ItemsCollectionVieww.cancelInteractiveMovement()
        }
    }
    

    

}
extension ItemsViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let theBox = Boxesarr[self.boxIndex!]
        arr = theBox.items
        return arr!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemsCell", for: indexPath) as? ItemsCollectionViewCell
        if(arr!.count>0){
            cell?.itemImageView.image = arr![indexPath.row]
            
        }
        if longPressedEnabled   {
            cell!.startAnimate()
        }else{
            cell!.stopAnimate()
        }
        return cell!
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Zoom the image when tapped
        let cell = ItemsCollectionVieww.cellForItem(at: indexPath) as! ItemsCollectionViewCell
        let imageView = UIImageView(image: cell.itemImageView.image)
        imageView.frame = self.view.frame
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        imageView.addGestureRecognizer(tap)
        
        self.view.addSubview(imageView)
    }
    
    // Use to back from full mode
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
}
extension ItemsViewController: ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for box in Boxesarr{
            if box.title == self.boxTitle{
                box.items.append(contentsOf: images)
                self.ItemsCollectionVieww.reloadData()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for box in Boxesarr{
            if box.title == self.boxTitle{
                box.items.append(contentsOf: images)
                
                self.ItemsCollectionVieww.reloadData()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

