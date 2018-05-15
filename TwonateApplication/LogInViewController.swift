//
//  LogInViewController.swift
//  TwonateApplication
//
//  Created by Gannon Barnett on 4/2/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit
import Firebase
import TwitterKit

class LogInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                let authToken = session?.authToken
                let authTokenSecret = session?.authTokenSecret
                
                self.authenticateUserWithFirebase(authToken: authToken!, authTokenSecret: authTokenSecret!)
                // ...
            } else {
                // ...
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        
    }
    
    func authenticateUserWithFirebase(authToken: String, authTokenSecret: String) {
        let credential = TwitterAuthProvider.credential(withToken: authToken, secret: authTokenSecret)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                print(error)
                return
            }
            // User is signed in
            // ...
            print("User successfully signed in with Firebase!")
            guard let id = Auth.auth().currentUser?.uid else { return }
            self.saveUserIDToFirebaseDatabase(id: id)
            self.performSegue(withIdentifier: "loginVCToHomescreenVC", sender: self)
        }
    }
    
    func saveUserIDToFirebaseDatabase(id: String) {
        let fundraisers = ""
        let profilePicture = ""
        let myRef = Database.database().reference().child("users/\(id)")
        let newValue = ["id" : id, "fundraisers" : fundraisers, "profilePicture" : profilePicture] as [String: Any]
        myRef.setValue(newValue) { (error, ref) in
            if error != nil {
                print(error?.localizedDescription ?? "Failed to update value")
            } else {
                print("Created user on Firebase database")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
