//
//  AddViewController.swift
//  babyhaha
//
//  Created by Sai~ on 11/21/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import Firebase
import DoneHUD
import ImagePicker

class AddViewController: UIViewController{

    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var categoryFirld: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    

    @IBAction func uploadButtonPressed(_ sender: UIButton) { //HERE
        //Present image picker
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self as? ImagePickerDelegate
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func backpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var tagOfBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.borderStyle = .roundedRect
        categoryFirld.borderStyle = .roundedRect
        // Do any additional setup after loading the view.
        
        self.hideKeyboard()
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        var newBox: Box = Box(title: titleField.text!, category: categoryFirld.text!, tag: tagOfBox.text!, coverImage: uploadImageView.image!) //HERE
        //Upload data to firebase
        uploadToFirebase(box: newBox)
        //Clear text fields
        titleField.text=""
        categoryFirld.text=""
        tagOfBox.text=""
        //Show HUD
        DoneHUD.showInView(self.view, message: "Added")
        
        //Exit view
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
            // Your code with delay
            self.dismiss(animated: true, completion: nil)
        }
        
        
        
        
    }
    
    func uploadToFirebase(box:Box){ //HERE
        //All boxes SHOULD have a unique title
        let ref = Storage.storage().reference().child("boxItems").child(box.title)
        let metaData = Data()
        let uploadTask = ref.putData(box.coverImage.jpegData(compressionQuality: 0.3)!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let size = metadata.size
            ref.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                let dictionaryValues = ["title": box.title,
                                "category": box.category,
                                "tag": box.tag,
                                "coverImage": downloadUrl.absoluteString] as [String : String]
                Database.database().reference().child("Boxes").child(box.title).setValue(dictionaryValues)
            }
        }
    }
}
    
extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension AddViewController: ImagePickerDelegate{ //HERE, THIS WHOLE extension
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        uploadImageView.image = images[0]
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
