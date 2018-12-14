//
//  HomeViewController.swift
//  babyhaha
//
//  Created by Sai~ on 11/19/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class HomeViewController: UIViewController, ModalHandler {
    func modalDismissed(range: Double, currLoc: CLLocation) {
        self.currentLoc = currLoc
        self.range = range
        filteredBundles = []
        filterBundlesbyLocation()
        homeCollectionView.reloadData()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="mapSegue"){
            let childVc = segue.destination as! MapViewController
            childVc.delegate = self
        }
        else if(segue.identifier=="homeBundleItemsSegue"){
            let childVc = segue.destination as! ItemsViewController
            childVc.boxSelected = self.boxSelected
        }
        
    }
    
    var allBundles = [Box]()
    var filteredBundles = [Box]()
    var databasehandle: DatabaseHandle?
    var ref:DatabaseReference?
    var currentLoc:CLLocation?
    var range: Double?
    var boxSelected:Box?
    
    @IBOutlet weak var homeCollectionView: HomeCollectionView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirebase()
        filterBundlesbyLocation()
        homeCollectionView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func getDataFromFirebase(){
        
        ref = Database.database().reference()
        databasehandle = ref?.child("Boxes").observe(.childAdded, with: { snapshot in
            
            if !snapshot.exists() { return }
            print(snapshot) // Its print all values including Snap (User)
            var datafir = snapshot.value as! [String:Any]
            Storage.storage().reference().child("boxItems").child(datafir["title"]! as! String).getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                if let _error = error{
                    print(_error)
                    
                } else {
                    if let data  = data {
                        let coverImg = UIImage(data: data)
                        
                        let gotBox = Box(title: datafir["title"]! as! String , category: datafir["category"]! as! String, tag: datafir["tag"]! as! String, coverImage:coverImg!, description:datafir["description"]! as! String, location: datafir["location"]! as! String, owner: datafir["owner"]! as! String)
                        if((datafir["items"]) != nil){
                            let dict = datafir["items"] as! [String:String]
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
                        
                    }
                }
            }
            
        })
    }
    func filterBundlesbyLocation(){
        filteredBundles = allBundles.filter({ box -> Bool in
            
            return isWithinRange(box: box)
        })
    }
    
    func isWithinRange(box: Box) -> Bool{
        let locArray = box.location.components(separatedBy: ",")
        let lat = Double(locArray[0])
        let long = Double(locArray[1])
        let boxLocation = CLLocation(latitude: lat!, longitude: long!)
        let distanceInMeters = boxLocation.distance(from: currentLoc!) // result is in meters
        if(distanceInMeters > range! ){
            return false
        }
        else{
            return true
        }
    }
    

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredBundles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeBundleCell", for: indexPath) as! HomeCollectionViewCell
        
        cell.homeBundleImage.image = filteredBundles[indexPath.row].coverImage
        cell.homeBundleTitle.text = filteredBundles[indexPath.row].title
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.boxSelected = filteredBundles[indexPath.row]
        performSegue(withIdentifier: "homeBundleItemsSegue", sender: self)
    }
    
    
    
}


