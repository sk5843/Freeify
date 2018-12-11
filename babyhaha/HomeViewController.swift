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
        let childVc = segue.destination as! MapViewController
        childVc.delegate = self
        
    }
    
    var allBundles = [Box]()
    var filteredBundles = [Box]()
    var databasehandle: DatabaseHandle?
    var ref:DatabaseReference?
    var currentLoc:CLLocation?
    var range: Double?
    
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
            var datafir = snapshot.value as? [String:String]
            Storage.storage().reference().child("boxItems").child(datafir!["title"]!).getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                if let _error = error{
                    print(_error)
                    
                } else {
                    if let data  = data {
                        let coverImg = UIImage(data: data)
                        
                        let gotBox = Box(title: datafir!["title"]! , category: datafir!["category"]!, tag: datafir!["tag"]!, coverImage:coverImg!, description:datafir!["description"]!, location: datafir!["location"]!, owner: datafir!["owner"]!)
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
    
    
    
}


