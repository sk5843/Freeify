//
//  SearchTableViewCell.swift
//  babyhaha
//
//  Created by Sai~ on 12/10/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var searchItemCategory: UILabel!
    
    @IBOutlet weak var searchItemLabel: UILabel!
    @IBOutlet weak var searchItemImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
