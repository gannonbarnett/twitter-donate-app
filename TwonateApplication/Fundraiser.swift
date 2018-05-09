//
//  Fundraiser.swift
//  TwonateApplication
//
//  Created by Daniel Korsunsky on 4/28/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit

class Fundraiser: NSObject {
    var name: String
    var progress: Double
    var handle: String
    var keyword: String = ""
    
    init(name: String, progress: Double, handle: String) {
        self.name = name
        self.progress = progress
        self.handle = handle
        
        super.init()
    }
    
    @IBAction func nameField(_ sender: UITextField) {name = sender.text!}
    
    @IBAction func handleField(_ sender: UITextField) {handle = sender.text!}
    
    @IBAction func keywordField(_ sender: UITextField) {keyword = sender.text!}
    
    @IBAction func perAmountField(_ sender: UITextField) {handle = sender.text!}
    
    @IBAction func maxAmountField(_ sender: UITextField) {handle = sender.text!}
    
    @IBAction func createFundraiser(_ sender: UITextField) {}
}
