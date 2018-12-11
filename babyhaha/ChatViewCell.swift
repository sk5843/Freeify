//
//  ChatViewCell.swift
//  babyhaha
//
//  Created by Sai~ on 12/3/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import AVFoundation

class ChatViewCell: UITableViewCell {

    var userId:String?

    @IBOutlet weak var chatImage: UIImageView!
    @IBAction func messengerPressed(_ sender: UIButton) {
        animateButton(button: sender)
        let systemSoundID: SystemSoundID = 1102
        AudioServicesPlaySystemSound (systemSoundID)
        var urlString = "fb-messenger://user-thread/"+userId!
            if let url = URL(string: urlString) {
                
                // Attempt to open in Messenger App first
                UIApplication.shared.open(url, options: [:], completionHandler: {
                    (success) in
                    
                    if success == false {
                        // Messenger is not installed. Open in browser instead.
                        var urlStr = "https://m.me/"+self.userId!
                        let url = URL(string: urlStr)
                        if UIApplication.shared.canOpenURL(url!) {
                            UIApplication.shared.open(url!)
                        }
                    }
                })
            }
        }
    
    @IBOutlet weak var chatUser: UILabel!
    @IBAction func chatDescription(_ sender: Any) {
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.chatImage.layer.cornerRadius = self.chatImage.frame.size.width / 2;
        self.chatImage.clipsToBounds = true;
        self.chatImage.layer.borderWidth = 1.5
        self.chatImage.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
