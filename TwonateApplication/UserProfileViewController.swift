//
//  UserProfileViewController.swift
//  TwonateApplication
//
//  Created by Max Goldberg on 5/29/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editUsername: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUsername()
    }
    
    func getUsername() {
        let ref2 = Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/name")
        ref2.observeSingleEvent(of: .value) { (DataSnapshot) in
            self.userName.text = DataSnapshot.value as! String
        }
        
    }
    
    // UITextFieldDelegateMethods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.userName.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.userName.text = textField.text!
        let ref = Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/name")
        ref.setValue(textField.text!)
        self.editUsername.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
