//
//  HomeViewController.swift
//  babyhaha
//
//  Created by Sai~ on 11/19/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var categories = ["Clothing", "Kitchenware", "Electronics"]
    
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
        cell.categoryLabel.text = categories[indexPath.row]
        return cell
    }
    
    
}


