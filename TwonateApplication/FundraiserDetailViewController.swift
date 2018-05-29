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
    
    var name = ""
    var goal = 0.0
    var bid = 0.0
    var leaderboard = [Leaderboard]()
    var userStatistics = [String : Int]()

    @IBOutlet weak var fundraiserName: UILabel!
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fundraiserName.text = name
        updateFundraiserDetails(fundraiserName: name)
    }
    

    func updateFundraiserDetails(fundraiserName: String) {
        var desiredLeaderboard = [Leaderboard]()
        var fundraiserID = ""
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
