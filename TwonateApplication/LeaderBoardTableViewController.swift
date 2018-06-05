//
//  LeaderBoardTableViewController.swift
//  TwonateApplication
//
//  Created by Gannon Barnett on 5/29/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit
import Firebase

class LeaderBoardTableViewController: UITableViewController {

    var donationData : [[Any]] = []
    //[totalRaised, fundraiser name, image]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getData() {
        donationData = []
        let ref = Database.database().reference().ref.child("fundraisers")
        ref.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            let storedFundraisers = (DataSnapshot.value!) as! [String : Any]
            for (_,v) in storedFundraisers {
                let name = (v as! [String : Any])["name"] as! String
                let totalRaised = (v as! [String : Any])["totalRaised"] as! Int
                let image = (v as! [String : Any])["image"] as! String
                
                self.donationData.append([totalRaised, name, image])
            }
            self.donationData = self.donationData.sorted(by: {($0[0] as! Int) > ($1[0] as! Int )})
            self.tableView.reloadData()
        })
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donationData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "realLeaderboardCell", for: indexPath) as! RealLeaderboardTableViewCell
        
        let data = donationData[indexPath.row]
        cell.position.text = String(indexPath.row + 1)
        cell.name.text = data[1] as! String
        cell.donation.text = String(data[0]  as! Int)
        
        let imageDownloadURL = URL(string: data[2] as! String)
        let i = MyIndicator()
        cell.fundraiserImage.kf.indicatorType = .custom(indicator: i)
        cell.fundraiserImage.kf.setImage(with: imageDownloadURL, options: [.transition(.fade(0.2))])
        
        

        return cell
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 103.0
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "leaderboardsVCtoDetailVC", sender: self)
        
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "leaderboardsVCtoDetailVC" {
            let fundraiserDetailVC = segue.destination as! FundraiserDetailViewController
            fundraiserDetailVC.name = donationData[self.tableView.indexPathForSelectedRow!.row][1] as! String
        }
    }
}
