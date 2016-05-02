//
//  ViewController.swift
//  twitterMini
//
//  Created by Tom O'Malley on 5/2/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import UIKit
import SafariServices
import OAuthSwift

class ViewController: UIViewController {
    
    let twitterBaseURL = "https://api.twitter.com/1.1/"
    
    var oauthswift : OAuth1Swift!
    var idForLoggedInUser : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let twitterSignInButton = UIButton()
        twitterSignInButton.backgroundColor = UIColor.blackColor()
        view.addSubview(twitterSignInButton)
        twitterSignInButton.translatesAutoresizingMaskIntoConstraints = false
        twitterSignInButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        twitterSignInButton.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        twitterSignInButton.setTitle("Sign In with Twitter", forState: .Normal)
        twitterSignInButton.addTarget(self, action: #selector(doOAuthTwitter), forControlEvents: .TouchUpInside)
    }
    
    func doOAuthTwitter(){
        let key = "CbE3BbqhqwxNbRdGCP5y2gDU2"
        let secret = "PxQy9075tg4QSZsLZNX3wwXEkG5fyuhtrAlNjM868sYRi6BCU8"
        let callback = "twittestIntrepid://"
        
        oauthswift = OAuth1Swift(
            consumerKey:    key,
            consumerSecret: secret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        
        oauthswift.authorize_url_handler = SafariURLHandler(viewController: self)
        oauthswift.authorizeWithCallbackURL( NSURL(string: callback)!, success: {
            credential, response, parameters in
            print(credential.oauth_token)
            print(credential.oauth_token_secret)
            print(parameters["user_id"])
            
            self.idForLoggedInUser = parameters["user_id"]
            self.fetchTimeline()
            }, failure: { error in
                print(error.localizedDescription)
            }
        )
    }
    
    func fetchTimeline(){
        if let idForLoggedInUser = idForLoggedInUser{
            let homeTimelineEndpoint = "statuses/home_timeline.json"
            let fullTimelineURL = "\(twitterBaseURL)\(homeTimelineEndpoint)?user_id=\(idForLoggedInUser)"
            print("hitting \(fullTimelineURL)")
            oauthswift.client.get(fullTimelineURL, success: { (data, response) in
                print("SUCCESS")
                do{
                    let dataObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    
                    // STATUS
                    if let statusDictionary = dataObject.firstObject as? [String:AnyObject],
                        let createdAt = statusDictionary["created_at"] as? String,
                        let text = statusDictionary["text"] as? String,
                        let likes = statusDictionary["favorite_count"] as? Int,
                        let retweets = statusDictionary["retweet_count"] as? Int {
                        print(createdAt)
                        print(text, likes, retweets)
            
                        // HASHTAGS
                        let hashtagDictionaries = statusDictionary["entities"]?["hashtags"] as? [[String:AnyObject]] ?? []
                        let hashtags = hashtagDictionaries.map { return $0["text"]! }
                        print(hashtags)
                        // ASK: do we need hashtags in their own property?
                        
                        // USER
                        if let userDictionary = statusDictionary["user"] as? [String:AnyObject],
                            let name = userDictionary["name"] as? String,
                            let screenName = userDictionary["screen_name"] as? String,
                            let profileImageURL = userDictionary["profile_image_url_https"] as? String {
                            
                            let user = TwitterUser(screenName: screenName, name: name, profileImageURL: profileImageURL)
                            let status = TwitterStatus(createdAt: createdAt, hashtags: hashtags as! [String], text: text, user: user, likes: likes, retweets: likes)
                            print(status)
                        }
                    }
                    print(dataObject.firstObject)
                } catch {
                    print(error)
                }
                }, failure: { (error) in
                    print("OOF:\(error.localizedDescription)")
            })
        } else {
            print("user is not logged in...")
        }
    }
}

