//
//  FundraisersViewController.swift
//  TwonateApplication
//
//  Created by Max Goldberg on 4/30/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit

class FundraisersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var fundraisers = [Fundraiser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        
        if let image = fundraisers[indexPath.row].image {
            cell.image.image = image
        }
        return cell
    }
    
}
