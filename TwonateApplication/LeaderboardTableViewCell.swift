//
//  LeaderboardTableViewCell.swift
//  TwonateApplication
//
//  Created by Gannon Barnett on 5/29/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet var totalDonatedAmount: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var position: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
