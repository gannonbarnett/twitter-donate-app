//
//  FundraiserDetailViewController.swift
//  TwonateApplication
//
//  Created by Max Goldberg on 5/29/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit
import Firebase
import UICircularProgressRing


class FundraiserDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var joinButton: UIButton!
    
    var name = ""
    var goal = 0.0
    var bid = 0.0
    var leaderboard = [Leaderboard]()
    var userStatistics = [String : Int]()

    var handle = ""
    var keywords = ""
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var keywordsLabel: UILabel!
    
    @IBOutlet weak var fundraiserName: UILabel!
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    
    @IBAction func joinButtonTouched(_ sender: Any) {
        // User has joined the fundraiser
        let ref = Database.database().reference().ref.child("users/\(Auth.auth().currentUser!.uid)/fundraisers")
        var currentFundraisers = ""
        ref.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            currentFundraisers = (DataSnapshot.value!) as! String
            
            var newValue = ""
            if currentFundraisers != "" {
                if currentFundraisers == self.name {
                    // Do Nothing
                } else {
                    newValue = currentFundraisers + "," + self.name
                }
            } else {
                newValue = self.name
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
                    if ((v as! [String : Any])["name"] as! String) == self.name {
                        joiningFundraiserID = k
                    }
                }
                var joiningKeywords = [String]()
                var usersPerKeyword = [Int]()
                
                //add to user statistcs
                Database.database().reference().ref.child("fundraisers/\(joiningFundraiserID)/user_statistics").child(Auth.auth().currentUser!.uid).setValue(0)
                
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
                    // Go to FundrasierDetailVC
                    
                    let alert = UIAlertController(title: "Fundraiser \(self.name) Joined", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Fantastic", style: .default, handler: nil))
                    self.updateFundraiserDetails(fundraiserName: self.name)
                    self.leaderboardTableView.reloadData()
                    self.present(alert, animated: true)
                    self.joinButton.isHidden = true
                })
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fundraiserName.text = name
        updateFundraiserDetails(fundraiserName: name)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        updateFundraiserDetails(fundraiserName: name)
        let ref5 = Database.database().reference().ref.child("users/\(Auth.auth().currentUser!.uid)/fundraisers")
        ref5.observeSingleEvent(of: .value) { (DataSnapshot) in
            let currentFundraisers2 = DataSnapshot.value as! String
            if currentFundraisers2.contains(self.name) {
                // hide join button
                self.joinButton.isHidden = true
            } else {
                self.joinButton.isHidden = false
            }
        }
    }
    
    func updateFundraiserDetails(fundraiserName: String) {
        var desiredLeaderboard = [Leaderboard]()
        var fundraiserID = ""
        keywords = ""
        handle = ""
        let ref = Database.database().reference().ref.child("fundraisers")
        ref.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            let storedFundraisers = (DataSnapshot.value!) as! [String : Any]
            for (k,v) in storedFundraisers {
                if ((v as! [String : Any])["name"] as! String) == fundraiserName {
                    fundraiserID = k
                }
            }

            let ref2 = Database.database().reference().ref.child("fundraisers/\(fundraiserID)")
            ref2.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                self.goal = Double((DataSnapshot.value as! [String : Any])["goal"] as! String)!
                self.bid = Double((DataSnapshot.value as! [String : Any])["bid"] as! String)!
                self.userStatistics = (DataSnapshot.value as! [String : Any])["user_statistics"] as! Dictionary<String, Int>
                self.handle = (DataSnapshot.value as! [String : Any])["handle"] as! String
                let keywordArray = (DataSnapshot.value as! [String : Any])["keywords"] as! [String : Any]
                self.keywords = ""
                self.keywordsLabel.text = ""
                for (k, _) in keywordArray {
                    if self.keywords != "" {
                        self.keywords = "\(self.keywords), " + k
                    }else {
                        self.keywords = k
                    }
                }
                
                self.keywordsLabel.text = self.keywords
                self.handleLabel.text = self.handle
                
                for (k,v) in self.userStatistics {
                    desiredLeaderboard.append(Leaderboard(username: k, totalDonatedAmount: String(self.bid * Double(v))))
                }
                self.leaderboard = desiredLeaderboard
                self.leaderboard = self.leaderboard.sorted(by: {$0.totalDonatedAmount > $1.totalDonatedAmount})
                self.leaderboardTableView.reloadData()
                self.setProgressRing() // Update the progress ring
            })
        })
    }

    
    func setProgressRing() {
        self.progressRing.animationStyle = kCAMediaTimingFunctionLinear
        var totalBidAmount = 0.0
        for (_,numBids) in userStatistics {
            totalBidAmount += (Double(numBids) * bid)
        }
        self.progressRing.setProgress(to: CGFloat((totalBidAmount/goal)*100), duration: 2.0)
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // UITableView Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leaderboard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell") as! LeaderboardTableViewCell
        cell.position.text = "#" + String(indexPath.row + 1)
        let ref5 = Database.database().reference().child("users/\(self.leaderboard[indexPath.row].username)")
        ref5.observeSingleEvent(of: .value) { (DataSnapshot) in
            cell.username.text = (DataSnapshot.value as! [String : Any])["name"] as! String
        }
        cell.totalDonatedAmount.text = "$" + self.leaderboard[indexPath.row].totalDonatedAmount + " Donated"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
