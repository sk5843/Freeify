//
//  SearchViewController.swift
//  babyhaha
//
//  Created by Sai~ on 11/20/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {
    
    var allBundles = [Box]()
    var filteredBundles = [Box]()
    var databasehandle: DatabaseHandle?
    var ref:DatabaseReference?
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirebase()
        searchBar.showsCancelButton = false
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
    
    
}



extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBundles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as? SearchTableViewCell else {return UITableViewCell()}
        cell.searchItemImage.image = filteredBundles[indexPath.row].coverImage
        cell.searchItemLabel.text = filteredBundles[indexPath.row].title
        cell.searchItemCategory.text = "Category: "+filteredBundles[indexPath.row].category
        return cell
        
    }
    
    
}

extension SearchViewController: UISearchBarDelegate{


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filteredBundles = allBundles.filter({ box -> Bool in
            guard let text = searchBar.text else {return false}
            return box.category.lowercased().contains(text.lowercased())
        })
        searchTableView.reloadData()
        searchBar.showsCancelButton = true
        

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredBundles = []
        searchBar.showsCancelButton = false
        self.searchBar.endEditing(true)
        searchTableView.reloadData()
    }
}


