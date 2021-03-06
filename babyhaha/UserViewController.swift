//
//  UserViewController.swift
//  babyhaha
//
//  Created by Sai~ on 11/20/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage



var boxCollectionViewgl: UICollectionView?
var Boxesarr = [Box]()
class UserViewController: UIViewController {
    
    
    var longPressedEnabled = false
    var databasehandle: DatabaseHandle?
    var ref:DatabaseReference?
    var boxSelected:Box?
    var allBundles = [Box]()
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var addBox: UIButton!
    @IBAction func donePressed(_ sender: Any) {
        animateButton(button: doneButton)
        
        //disable the shake and hide done button
        doneButton.isHidden = true
        addBox.isHidden = false
        longPressedEnabled = false
        
        self.boxCollectionView.reloadData()
        
    }
    @IBAction func addBoxPressed(_ sender: Any) {
        animateButton(button: addBox)
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
    
    @IBOutlet weak var boxCollectionView: ProfileBundlesCollection!
    @IBAction func logOutButton(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)

    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var fbButton: UIButton!
    
    
    @IBAction func fbButtonPressed(_ sender: Any) {
        let fbUrl: String? = "fb://profile?app_scoped_user_id="+username!
        if let url = URL(string: fbUrl!) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],completionHandler: { (success) in
                    print("Open fb://profile/<id>: \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open fb://profile/<id>: \(success)")
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Boxesarr = []
        doneButton.isHidden=true
        boxCollectionViewgl = boxCollectionView
        //getData from firebase
        getDataFromFirebase()
        filterBundles()
        //Initial set up of the profile picture frame (Round)
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        self.profilePicture.layer.borderWidth = 1.5
        self.profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.image = profileImage
        //Init name
        Name.text = name
        Name.textColor = UIColor.white
        
        // Do any additional setup after loading the view.
        
        //adding longpress gesture over UICollectionView
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        boxCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    func filterBundles(){
        Boxesarr = []
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Boxesarr = allBundles.filter({ box -> Bool in
            return box.owner == uid
        })
        self.boxCollectionView.reloadData()
    }
    
    @objc func longTap(_ gesture: UIGestureRecognizer){
        
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = boxCollectionView.indexPathForItem(at: gesture.location(in: boxCollectionView)) else {
                return
            }
            boxCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            boxCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            boxCollectionView.endInteractiveMovement()
            doneButton.isHidden = false
            addBox.isHidden=true
            longPressedEnabled = true
            self.boxCollectionView.reloadData()
        default:
            boxCollectionView.cancelInteractiveMovement()
        }
    }
    
    
    func getDataFromFirebase(){
        print("called")
        self.allBundles = []
        ref = Database.database().reference()
        ref?.child("Boxes").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() { return }
            print(snapshot) // Its print all values including Snap (User)
            for child in snapshot.children{
                let data = child as! DataSnapshot
                var datafir = data.value as! [String:Any]
                Storage.storage().reference().child("boxItems").child(datafir["title"]! as! String).getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                    if let _error = error{
                        print(_error)
                        
                    } else {
                        if let data  = data {
                            let coverImg = UIImage(data: data)
                            //Retrieve the bundle
                            let gotBox = Box(title: datafir["title"]! as! String , category: datafir["category"]! as! String, tag: datafir["tag"]! as! String, coverImage:coverImg!, description:datafir["description"]! as! String, location: datafir["location"]! as! String, owner: datafir["owner"]! as! String)
                            if((datafir["items"]) != nil){
                                let dict = datafir["items"] as! [String:String]
                                //Retrieve the images for the bundle
                                for (key,value) in dict{
                                    let ImgRef = Storage.storage().reference(forURL: value )
                                    ImgRef.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                                        if let _error = error{
                                            print(_error)
                                            
                                        } else {
                                            if let data  = data {
                                                let Img = UIImage(data: data)
                                                gotBox.items.append(Img!)
                                            }
                                        }
                                    }
                                }
                            }
                            self.allBundles.append(gotBox)
                            self.filterBundles()
                        }
                    }
                }
            }
            
            
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemsSegue"{
            let vc = segue.destination as? ItemsViewController
            vc?.boxSelected = self.boxSelected
            vc?.itemsAddBtnIsHidden = false
            vc?.contactViewIsHidden = true
        }
        if segue.identifier == "addBoxSegue"{
            let vc2 = segue.destination as? AddViewController
            vc2?.delegate = self
            
        }
    }
    
    
}

extension UserViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (Boxesarr.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileBundleCell", for: indexPath) as? ProfileBundleCell
        
        cell?.boxTitle.text = Boxesarr[indexPath.row].title
        cell?.coverImg.image = Boxesarr[indexPath.row].coverImage
        
        if longPressedEnabled   {
            cell!.startAnimate()
        }else{
            cell!.stopAnimate()
        }
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.boxSelected = Boxesarr[indexPath.row]
        performSegue(withIdentifier: "itemsSegue", sender: self)
    }
    
    
    
}
