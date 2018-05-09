//
//  SearchViewController.swift
//  TwonateApplication
//
//  Created by Daniel Korsunsky on 4/28/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var fundraisers: [String] = ["banteng.png", "bear.png", "bison.png", "boar.png", "deer.png", "dog.png", "fox.png", "ibex.png", "mallard.png", "moose.png", "ghostbunny.png", "ram.png"]
    var count = 0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fundraisers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fundraiserCell", for: indexPath) as! FundraiserCollectionViewCell
        
        cell.image.image = UIImage(named: fundraisers[count])
        self.count += 1
        
        return cell
        
    }
    
    var fundraiserCollection = FundraiserCollection()
    
    @IBOutlet weak var fundraiserCollectionView: UICollectionView!
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fundraiserCollection.fundraisers.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
//        let item = fundraiserCollection.fundraisers[indexPath.row]
//
//        cell.textLabel?.text = item.name
//        cell.detailTextLabel?.text = "\(item.progress * 100)%"
//
//        return cell
//    }
    
    @IBAction func addNewFundraiser(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let statusBarHeight = UIApplication.shared.statusBarFrame.height
//        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
//        tableView.contentInset = insets
//        tableView.scrollIndicatorInsets = insets
    }

}
