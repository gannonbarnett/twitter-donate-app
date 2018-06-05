//
//  CreateFundraiserViewController.swift
//  TwonateApplication
//
//  Created by Max Goldberg on 5/15/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit
import Firebase

class CreateFundraiserViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var createActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var createButton: UIButton!
    
    var fundraiserName = ""
    var fundraiserTargetTwitterHandle = ""
    var fundraiserKeywords = [String]()
    var fundraiserBid = ""
    var fundraiserGoal = ""
    var fundraiserImage: UIImage?
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        
        // Resign keyboard when user touches somewhere on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateFundraiserViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        createActivityIndicator.isHidden = true
    }
    
    // Create a new fundraiser object on Firebase Database
    @IBAction func addFundraiser(_ sender: UIButton) {
        if self.fundraiserName == "" || self.fundraiserTargetTwitterHandle == "" || self.fundraiserKeywords.isEmpty || self.fundraiserBid == "" || self.fundraiserGoal == "" || self.fundraiserImage == nil {
            let alert = UIAlertController(title: "Couldn't Create Fundraiser", message: "Please make sure all fields are filled and try again!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            createActivityIndicator.isHidden = false
            createActivityIndicator.startAnimating()
            createButton.isEnabled = false
            createFundraiser(name: self.fundraiserName, targetHandle: self.fundraiserTargetTwitterHandle, keywords: self.fundraiserKeywords, bid: self.fundraiserBid, goal: self.fundraiserGoal, image: self.fundraiserImage) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    func createFundraiser(name: String, targetHandle: String, keywords: [String], bid: String, goal: String, image: UIImage?, completion: @escaping () -> Void) {
        
        let randomID = randomString(length: 19)
        
        let myRef = Database.database().reference().child("fundraisers/\(randomID)")
        let newValue = ["handle" : targetHandle, "name" : name, "bid" : bid, "goal" : goal, "user_statistics" : [Auth.auth().currentUser!.uid : 0]] as [String: Any]
        myRef.setValue(newValue) { (error, ref) in
            if error != nil {
                print(error?.localizedDescription ?? "Failed to update value")
            } else {
                print("Created fundraiser on Firebase database")
                
                if image != nil {
                    let imageData = UIImageJPEGRepresentation(image!, 0.8)
                    let storageRef = Storage.storage().reference()
                    let fundraiserImagesRef = storageRef.child("FundraiserImages/\(randomID)")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpg"
                    
                    // Upload the image to the path "FundraiserImages/FUNDRAISERID.jpg"
                    let uploadTask = fundraiserImagesRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                        guard let metadata = metadata else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        
            
                        // You can also access to download URL after upload.
                        fundraiserImagesRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred!
                                return
                            }
                            
                            let myRef3 = Database.database().reference().child("fundraisers/\(randomID)/image")
                            let newValue3 = downloadURL.absoluteString
                            myRef3.setValue(newValue3) { (error, ref) in
                                if error != nil {
                                    print(error?.localizedDescription ?? "Failed to update value")
                                } else {
                                    print("Added fundraiser image on Firebase database")
                                }
                                completion()
                            }
                            
                             Database.database().reference().child("fundraisers/\(randomID)/totalRaised").setValue(0)
                        }
                    }
                }
                
                for keyword in keywords {
                    let myRef2 = Database.database().reference().child("fundraisers/\(randomID)/keywords/\(keyword)")
                    let newValue2 = [Auth.auth().currentUser?.uid]
                    myRef2.setValue(newValue2) { (error, ref) in
                        if error != nil {
                            print(error?.localizedDescription ?? "Failed to update value")
                        } else {
                            print("Updated keywords on Firebase database")
                        }
                    }
                }
                
                let myRef4 = Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/fundraisers")
                var currentFundraisers = ""
                
                myRef4.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    currentFundraisers = (DataSnapshot.value!) as! String
                    
                    var newValue4 = ""
                    if currentFundraisers != "" {
                        newValue4 = currentFundraisers + "," + self.fundraiserName
                    } else {
                        newValue4 = self.fundraiserName
                    }
                    myRef4.setValue(newValue4) { (error, ref) in
                        if error != nil {
                            print(error?.localizedDescription ?? "Failed to update value")
                        } else {
                            print("Updated user's fundraisers on Firebase database")
                        }
                    }
                })
                
                Database.database().reference().child("activeHandles/" + targetHandle + "/fundraisers/" + randomID).setValue(randomID);
                
                //check if handle exists already
                Database.database().reference().child("activeHandles").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild(targetHandle){
                        Database.database().reference().child("activeHandles/" + targetHandle + "/lastID").setValue(0);
                    }
                })
            }
        }
        
    }
    
    
    @IBAction func addImage(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            self.fundraiserName = textField.text!
        } else if textField.tag == 2 {
            self.fundraiserTargetTwitterHandle = textField.text!
        } else if textField.tag == 3 {
            var keywords = [String]()
            let parsedKeywordString = textField.text!.components(separatedBy: ",")
            for keyword in parsedKeywordString {
                keywords.append(keyword)
            }
            self.fundraiserKeywords = keywords
        } else if textField.tag == 4 {
            self.fundraiserBid = textField.text!
        } else if textField.tag == 5 {
            self.fundraiserGoal = textField.text!
        }
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    // Helps us generate a random fundraiser ID
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
    // Image Picker Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            fundraiserImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
