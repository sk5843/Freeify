//
//  HomeTable.swift
//  babyhaha
//
//  Created by Duo Zheng on 11/30/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit

class HomeTable: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    override func awakeFromNib() {
        self.delegate = self
        self.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as!
                CategoryCell
            return cell
    
    }
}
