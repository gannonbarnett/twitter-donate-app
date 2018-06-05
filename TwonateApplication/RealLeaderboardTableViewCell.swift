//
//  RealLeaderboardTableViewCell.swift
//  TwonateApplication
//
//  Created by Gannon Barnett on 5/29/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit

class RealLeaderboardTableViewCell: UITableViewCell {

    @IBOutlet var position: UILabel!
    @IBOutlet var donation: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var fundraiserImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
