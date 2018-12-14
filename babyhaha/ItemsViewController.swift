//
//  ItemsViewController.swift
//  babyhaha
//
//  Created by Sai~ on 12/2/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import ImagePicker
import Firebase

//Global variables
var itCView: ItemsCollectionView?
class ItemsViewController: UIViewController {

    @IBOutlet weak var boxTitleLabel: UILabel!
    
    @IBOutlet weak var boxCategoryLabel: UILabel!
    
    @IBOutlet weak var boxDescription: UILabel!
    
    
    var boxSelected:Box!
    //var itemsArray=[UIImage]()
    var longPressedEnabled = false
    var databasehandle: DatabaseHandle?
    var ref:DatabaseReference?

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
        //adding longpress gesture over UICollectionView
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        ItemsCollectionVieww.addGestureRecognizer(longPressGesture)
        //Init view
        initializeView()
        //getDataFromFirebase()
        
    }
    
    func initializeView(){
        
        self.boxTitleLabel.text = boxSelected.title
        self.boxCategoryLabel.text = boxSelected.category
        self.boxDescription.text = boxSelected.description
        //self.itemsArray = boxSelected.items
    
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
        
            return boxSelected.items.count
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemsCell", for: indexPath) as? ItemsCollectionViewCell
        if(boxSelected.items.count>0){
            cell?.itemImageView.image = boxSelected.items[indexPath.row]
            
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
        
        uploadToFirebase(items: images)
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        uploadToFirebase(items: images)
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirebase(items: [UIImage]){
        //first add to local array and reload data
        boxSelected.items.append(contentsOf: items)
        self.ItemsCollectionVieww.reloadData()
        //All boxes SHOULD have a unique title
        let ref = Storage.storage().reference().child("Items").child(boxSelected.title)
        for image in items{
            let imageName = NSUUID().uuidString
            let storageRef = ref.child(imageName)
            guard let uplodaData = image.jpegData(compressionQuality: 0.3) else{
                return
            }
            
            let uploadTask = storageRef.putData(uplodaData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                storageRef.downloadURL { (url, error) in
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    let ref2 = Database.database().reference().child("Boxes").child(self.boxSelected.title).child("items")
                    let autoID = ref2.childByAutoId().key
                    ref2.child(autoID!).setValue(url?.absoluteString)
                    
                }
            }
            
            
        }
        
        
    }
    
    
}

