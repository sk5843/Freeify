//
//  SearchViewController.swift
//  babyhaha
//
//  Created by Sai~ on 11/20/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import Firebase


/**
    Handles the search screen to search bundles filtered by category.
 
    **IMPORTANT :** The search function works by filtering using the category of the bundle.
    So while searching, search using the category, not the name of the bundle.
 */
class SearchViewController: UIViewController {
    
    ///Stores all the bundles in our database
    var allBundles = [Box]()
    /**Stores all the filtered bundles.
    These are the bundles filtered by category, which will be displayed on the search screen.*/
    var filteredBundles = [Box]()
    var databasehandle: DatabaseHandle?
    var ref:DatabaseReference?
    
    ///Reference to the searchbar where we type our search query
    @IBOutlet weak var searchBar: UISearchBar!
    ///The table view which is populated with all the bundles that matches our search query. Each cell in this table view is a bundle.
    @IBOutlet weak var searchTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirebase()
        searchBar.showsCancelButton = false
        // Do any additional setup after loading the view.
    }
    
    ///Gets all the bundles in our Firebase database and puts it into an array of type "Box"
    func getDataFromFirebase(){
        
        ref = Database.database().reference()
        databasehandle = ref?.child("Boxes").observe(.childAdded, with: { snapshot in
            
            if !snapshot.exists() { return }
            print(snapshot) // Its print all values including Snap (User)
            var datafir = snapshot.value as? [String:Any]
            Storage.storage().reference().child("boxItems").child(datafir!["title"]! as! String).getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                if let _error = error{
                    print(_error)
                    
                } else {
                    if let data  = data {
                        let coverImg = UIImage(data: data)
                        
                        let gotBox = Box(title: datafir!["title"]! as! String , category: datafir!["category"]! as! String, tag: datafir!["tag"]! as! String, coverImage:coverImg!, description:datafir!["description"]! as! String, location: datafir!["location"]! as! String, owner: datafir!["owner"]! as! String)
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
        ///Filters the bundles based on category.
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


