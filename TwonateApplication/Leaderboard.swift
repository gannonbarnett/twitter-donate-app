//
//  Leaderboard.swift
//  TwonateApplication
//
//  Created by Max Goldberg on 5/29/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import Foundation


struct Leaderboard {
    
    var username = ""
    var totalDonatedAmount = ""
    
    init(username: String, totalDonatedAmount: String) {
        self.username = username
        self.totalDonatedAmount = totalDonatedAmount
    }
}
