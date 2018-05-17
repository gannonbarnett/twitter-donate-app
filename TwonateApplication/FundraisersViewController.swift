//
//  FundraisersViewController.swift
//  TwonateApplication
//
//  Created by Max Goldberg on 4/30/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


struct MyIndicator: Indicator {
    let view: UIView = UIView()
    
    func startAnimatingView() { view.isHidden = false }
    func stopAnimatingView() { view.isHidden = true }
    
    init() {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = UIColor(red: 160.0/255.0, green: 32.0/255.0, blue: 240.0/255.0, alpha: 1.0/1.0)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
}


class FundraisersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {

    var fundraisers = [Fundraiser]()
    var allFundraisers = [Fundraiser]()
    var filteredFundraisers = [Fundraiser]()
    
    @IBOutlet weak var fundraiserCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fundraisers.removeAll()
        getFundraisers() {
            self.fundraiserCollectionView.reloadData()
            self.allFundraisers = self.fundraisers
        }
    }
    
    func getFundraisers(completion: @escaping () -> Void) {
        let myRef = Database.database().reference().child("fundraisers")
        myRef.observeSingleEvent(of: .value) { (DataSnapshot) in
            let fundraisers = DataSnapshot.value as? [String : Any]
            for fundraiser in fundraisers! {
                let name = (fundraiser.value as! [String : Any])["name"]
                let handle = (fundraiser.value as! [String : Any])["handle"]
                let image = (fundraiser.value as! [String : Any])["image"]
                let bid = (fundraiser.value as! [String : Any])["bid"]
                let goal = (fundraiser.value as! [String : Any])["goal"]
                var keywords = [String]()
                
                for keyword in ((fundraiser.value as! [String : Any])["keywords"]) as! [String : Any] {
                    keywords.append(keyword.key)
                }
                
                self.fundraisers.append(Fundraiser(name: name as! String, handle: handle as! String, image: image as! String, keywords: keywords, bid: String(describing: bid), goal: String(describing: goal)))
            }
            completion()
        }
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UICollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fundraisers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fundraiserCell", for: indexPath) as! FundraiserCollectionViewCell
        cell.name.text = fundraisers[indexPath.row].name
        
        let imageDownloadURL = URL(string: fundraisers[indexPath.row].image)
        let i = MyIndicator()
        cell.image.kf.indicatorType = .custom(indicator: i)
        cell.image.kf.setImage(with: imageDownloadURL, options: [.transition(.fade(0.2))])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Confirm that user wants to join this fundraiser
        let alert = UIAlertController(title: "\(self.fundraisers[indexPath.row].name)", message: "Are you sure that you would like to join this fundraiser?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (UIAlertAction) in
            // User has joined the fundraiser
            let ref = Database.database().reference().ref.child("users/\(Auth.auth().currentUser!.uid)/fundraisers")
            var currentFundraisers = ""
            ref.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                currentFundraisers = (DataSnapshot.value!) as! String
                
                var newValue = ""
                if currentFundraisers != "" {
                    if currentFundraisers == self.fundraisers[indexPath.row].name {
                        // Do Nothing
                    } else {
                        newValue = currentFundraisers + "," + self.fundraisers[indexPath.row].name
                    }
                } else {
                    newValue = self.fundraisers[indexPath.row].name
                }
                ref.setValue(newValue) { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription ?? "Failed to update value")
                    } else {
                        print("Updated user's fundraisers on Firebase database")
                    }
                }
                
                var joiningFundraiserID = ""
                let ref2 = Database.database().reference().ref.child("fundraisers")
                ref2.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    let storedFundraisers = (DataSnapshot.value!) as! [String : Any]
                    for (k,v) in storedFundraisers {
                        if ((v as! [String : Any])["name"] as! String) == self.fundraisers[indexPath.row].name {
                            joiningFundraiserID = k
                        }
                    }
                    var joiningKeywords = [String]()
                    var usersPerKeyword = [Int]()
                    let ref3 = Database.database().reference().ref.child("fundraisers/\(joiningFundraiserID)/keywords")
                    ref3.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                        let keywords = (DataSnapshot.value!) as! [String : Any]
                        for keyword in keywords {
                            joiningKeywords.append(keyword.key)
                            usersPerKeyword.append((keyword.value as! [Any]).count)
                        }
                        
                        for i in 0..<joiningKeywords.count {
                            let ref4 = Database.database().reference().ref.child("fundraisers/\(joiningFundraiserID)/keywords/\(joiningKeywords[i])")
                            ref4.updateChildValues(["\(usersPerKeyword[i])" : "\(Auth.auth().currentUser!.uid)"])
                        }
                    })
                })
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // UITextField Delegate Methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text! != "" {
            self.fundraisers = self.allFundraisers
            self.filteredFundraisers = fundraisers.filter{$0.name.lowercased().contains(textField.text!.lowercased())}
            self.fundraisers = filteredFundraisers
            self.fundraiserCollectionView.reloadData()
        } else {
            self.fundraisers = self.allFundraisers
            self.fundraiserCollectionView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
