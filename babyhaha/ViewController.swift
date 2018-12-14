//
//  ViewController.swift
//  Freeify
//
//  Created by Sai~ on 11/14/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit

import Firebase
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import SVProgressHUD
import SwiftyJSON
import FirebaseStorage
import FirebaseDatabase
import Spring
 
//User info
var name: String? = ""
var username: String? = ""
var email: String? = ""
var profileImage: UIImage?

class ViewController: UIViewController {
    
    @IBOutlet weak var loginWithFb: UIButton!

    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var logInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        roundIt(button: loginWithFb)
        roundIt(button: signUpBtn)
        roundIt(button: logInBtn)

    }
    
    func roundIt(button: UIButton){
        button.layer.cornerRadius = loginWithFb.frame.height/2;
        button.clipsToBounds = true
    }
    
    @objc func update() {
        SVProgressHUD.dismiss()
        //go to home screen
        self.performSegue(withIdentifier: "homescreen", sender: nil)
    }

    
    @IBAction func fbButtonPressed(_ sender: Any) {

        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile,.email], viewController: self) {(result) in
            switch result{
            case.success(grantedPermissions: _, declinedPermissions: _, token: _):
                self.signIntoFirebase();
                print("Successfully logged into Facebook")
                self.showHud()
            case.failed(let err):
                print(err);
            case.cancelled:
                print("cancelled")
            }
            
        }
    }
    
    func showHud(){
        //progress HUD things
        SVProgressHUD.setRingRadius(62)
        //SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setRingThickness(5)
        SVProgressHUD.show()
        //With Dispatch Queue
        DispatchQueue.global(qos: .userInitiated).async {
            SVProgressHUD.show()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
            }
        }
    }
    
    
    fileprivate func signIntoFirebase(){
        
        guard let authenticationToken = AccessToken.current?.authenticationToken else {return}
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        Auth.auth().signIn(with: credential) { (user, err) in
            if let err = err {
                print(err)
                return
                
            }
            self.fetchFacebookUser()
        }
        
    }
    
    fileprivate func fetchFacebookUser() {
        print("entered fetch")
        let graphRequestConnection = GraphRequestConnection()
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, picture.type(large)"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
        graphRequestConnection.add(graphRequest, completion: { (httpResponse, result) in
            switch result {
            case .success(response: let response):
                
                guard let responseDict = response.dictionaryValue else { return }
                
                let json = JSON(responseDict)
                name = json["name"].string
                email = json["email"].string
                username = json["id"].string
                guard let profilePictureUrl = json["picture"]["data"]["url"].string else { return }
                guard let url = URL(string: profilePictureUrl) else {return }
                
                URLSession.shared.dataTask(with: url) { (data, response, err) in
                    if err != nil {
                        guard let err = err else { return }
                        print(err)
                        return
                    }
                    guard let data = data else { return }
                    profileImage = UIImage(data: data)
                    self.saveUserIntoFirebaseDatabase()
                    
                    }.resume()
                
                break
            case .failed(let err):
                print(err)
                break
            }
        })
        graphRequestConnection.start()
        
        
    }
    
    fileprivate func saveUserIntoFirebaseDatabase() {
        print("Entered this")
        guard let uid = Auth.auth().currentUser?.uid,
            let name = name,
            let username = username,
            let email = email,
            let profileImage = profileImage,
            let profileImageUploadData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        let fileName = UUID().uuidString
        
        
        let storageRef = Storage.storage().reference().child("profileImages").child(fileName)
        let metaData = Data()
        
        let uploadTask = storageRef.putData(profileImageUploadData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let size = metadata.size
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                print("Successfully uploaded profile image into Firebase storage with URL:", downloadUrl)
                
                
                guard let uid =  Auth.auth().currentUser?.uid else { return }
                
                let dictionaryValues = ["name": name,
                                        "email": email,
                                        "username": username,
                                        "profileImageUrl": downloadUrl.absoluteString]
                let values = [uid : dictionaryValues]
                
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        print(err)
                        return
                    }
                    print("Successfully saved user info into Firebase database")
                    // after successfull save dismiss the welcome view controller
                })
            
            }
        }
        
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            print("Logged in")
        }
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
    }
    
    
    
    
}
