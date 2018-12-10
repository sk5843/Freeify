//
//  ChatViewController.swift
//  babyhaha
//
//  Created by Sai~ on 11/20/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {
    var arrayOfUserImages = ["fadri","soda","duo"]
    var arrayOfUsers = ["Fadri Hober", "Soda Pilipda", "Duo Zheng"]
    var arrayOfUserId = ["fadri.horber.9","sodananana","duo.zheng.9"]
    var noOfRows = 3
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfUserId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatViewCell
        cell?.chatImage.image = UIImage(named: arrayOfUserImages[indexPath.row])
        cell?.chatUser.text = arrayOfUsers[indexPath.row]
        cell?.userId = arrayOfUserId[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            noOfRows-=1
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    
}
