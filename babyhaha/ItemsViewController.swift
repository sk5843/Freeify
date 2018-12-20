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
import AVFoundation
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase


class ItemsViewController: UIViewController {
    
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        animateButton(button: doneBtn)
        
        //disable the shake and hide done button
        doneBtn.isHidden = true
        itemsAddbtn.isHidden = false
        longPressedEnabled = false
        
        self.ItemsCollectionVieww.reloadData()
    }
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var contactView: UIView!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userMessenger: UIButton!
    
    @IBAction func usermessengerButtonPressed(_ sender: UIButton) {
        animateButton(button: sender)
        let systemSoundID: SystemSoundID = 1102
        AudioServicesPlaySystemSound (systemSoundID)
        var urlString = "fb-messenger://user-thread/"+self.userID!
        if let url = URL(string: urlString) {
            
            // Attempt to open in Messenger App first
            UIApplication.shared.open(url, options: [:], completionHandler: {
                (success) in
                
                if success == false {
                    // Messenger is not installed. Open in browser instead.
                    var urlStr = "https://m.me/"+self.userID!
                    let url = URL(string: urlStr)
                    if UIApplication.shared.canOpenURL(url!) {
                        UIApplication.shared.open(url!)
                    }
                }
            })
        }
        
    }
    func animateButton(button:UIButton){
        button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        button.transform = .identity
            },
                       completion: nil)
    }
    

    @IBOutlet weak var boxTitleLabel: UILabel!
    
    @IBOutlet weak var boxCategoryLabel: UILabel!
    
    @IBOutlet weak var boxDescription: UILabel!
    
    
    var boxSelected:Box!
    var longPressedEnabled = false
    var databasehandle: DatabaseHandle?
    var ref:DatabaseReference?
    var userID:String?
    var itemsAddBtnIsHidden = false
    var contactViewIsHidden = false

    @IBOutlet weak var ItemsCollectionVieww: ItemsCollectionView!

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var itemsAddbtn: UIButton!

    //Add item
    @IBAction func itemsAddPressed(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self as? ImagePickerDelegate
        present(imagePickerController, animated: true, completion: nil)
        
    }
    //Go back
    @IBAction func backBtnPressed(_ sender: Any) {
        self.contactView.isHidden = false
        self.itemsAddbtn.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //adding longpress gesture over UICollectionView
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        ItemsCollectionVieww.addGestureRecognizer(longPressGesture)
        //Init view
        initializeView()
        
        
    }
    
    func initializeView(){
        //Hide stuff according to segues
        if(itemsAddBtnIsHidden){
            itemsAddbtn.isHidden = true
        }
        if(contactViewIsHidden){
            contactView.isHidden = true
        }
        doneBtn.isHidden = true
        self.boxDescription.layer.borderColor = UIColor.black.cgColor
        //Display the bundle information
        self.boxTitleLabel.text = boxSelected.title
        self.boxCategoryLabel.text = "Category: "+boxSelected.category
        self.boxDescription.text = boxSelected.description
        let ref = Database.database().reference().child("users").child(boxSelected.owner)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as! [String:String]
            let ImgRef = Storage.storage().reference(forURL: dict["profileImageUrl"]! )
            ImgRef.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                if let _error = error{
                    print(_error)
                    
                } else {
                    if let data  = data {
                        let Img = UIImage(data: data)
                        self.userImage.image = Img
                    }
                }
            }
            self.userName.text = dict["name"]
            self.userID = dict["username"]
        })
        //Round the Imageview
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
        self.userImage.clipsToBounds = true;
        self.userImage.layer.borderWidth = 1.5
        self.userImage.layer.borderColor = UIColor.clear.cgColor
        
        
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
            doneBtn.isHidden = false
            itemsAddbtn.isHidden=true
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
        cell?.delegate = self
        if(boxSelected.items.count>0){
            cell?.itemImageView.image = boxSelected.items[indexPath.row]
            cell?.itemsRemBtn.tag = indexPath.row
            
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

extension ItemsViewController: ItemsCellDelegate{
    func itemsRemBtnPressed(index: Int) {
        //Remove from local array
        boxSelected.items.remove(at: index)
        self.ItemsCollectionVieww.reloadData()
        //remove from Database
        removeItemFromDatabase(at: index)
        
    }
    
    func removeItemFromDatabase(at: Int){
        print(at)
        var i = 0
        let ref = Database.database().reference().child("Boxes").child(boxSelected.title).child("items")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if(i==at){
                    print(snap.key)
                    ref.child(snap.key).removeValue()
                    break
                }
                i+=1
            }
        })
        
    }
    
    
}
