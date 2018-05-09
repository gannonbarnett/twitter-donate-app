//
//  FundraiserCollection.swift
//  TwonateApplication
//
//  Created by Daniel Korsunsky on 4/28/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit

class FundraiserCollection {
    var fundraisers = [Fundraiser]()
    
    init() {
        createFundraiser(name: "Environment", progress: 0.59, handle: "@EPA")
        createFundraiser(name: "Holocaust", progress: 0.10, handle: "@RememberUs")
        createFundraiser(name: "School", progress: 0.42, handle: "@NSHS")
        createFundraiser(name: "Trump", progress: 0.79, handle: "@realDonaldTrump")
        createFundraiser(name: "Daniel's Birthday", progress: 0.65, handle: "@danielkorsunsky")
    }
    
    @discardableResult func createFundraiser(name: String, progress: Double, handle: String) -> Fundraiser {
        let newFundraiser = Fundraiser(name: name, progress: progress, handle: handle)
        fundraisers.append(newFundraiser)
        return newFundraiser
    }
}
