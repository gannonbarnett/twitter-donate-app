//
//  TwitterFunctions.swift
//  TwonateApplication
//
//  Created by Gannon Barnett on 3/26/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import Foundation

var postArray : [String] = []
var handle = "realdonaldtrump"

func getUserTweetTexts(completion: @escaping () -> Void) {
    
    let client = TWTRAPIClient(userID: nil)
    let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    let params = ["screen_name": handle, "tweet_mode": "extended"]
    var clientError : NSError?
    
    let request = client.urlRequest(withMethod: "GET", urlString: url, parameters: params, error: &clientError)
    
    client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
        if connectionError != nil {
            print("Error: \(String(describing: connectionError))")
            completion()
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: [])
            if let jsonArray = json as? [Any] {
                postArray = []
                for postObject in jsonArray{
                    if let postDictionary = postObject as? [String : Any] {
                        postArray.append(postDictionary["full_text"] as! String)
                    }
                }
               completion()
            }
        } catch let jsonError as NSError {
            print("json error: \(jsonError.localizedDescription)")
            completion()
        }
    }
    
}

func searchTextForKeywords(text: String, keywords: [String]) -> [Bool]{
    var results : [Bool] = []
    for keyword in keywords {
        if text.contains(keyword) {
            results.append(true)
        }else {
            results.append(false)
        }
    }
    return results
}

func searchForTwitterHandle() {
    let client = TWTRAPIClient(userID: nil)
        // make requests with client
    
    let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    let params = ["screen_name": "gannonbarnett"]
    var clientError : NSError?
    
    let request = client.urlRequest(withMethod: "GET", urlString: url, parameters: params, error: &clientError)
    
    client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
        if connectionError != nil {
            print("Error: \(connectionError)")
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: [])
            print("json: \(json)")
        } catch let jsonError as NSError {
            print("json error: \(jsonError.localizedDescription)")
        }
    }
}

