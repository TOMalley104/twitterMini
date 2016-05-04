//
//  TwitterAPIClient.swift
//  twitterMini
//
//  Created by Tom O'Malley on 5/3/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import OAuthSwift
import Intrepid

enum TwitterMiniError: ErrorType {
    case AuthenticationFailure
    case RequestFailure
}

class TwitterAPIClient {
    let twitterBaseURL = "https://api.twitter.com/1.1/"
    let callbackURL = "twittestIntrepid://"
    
    let oauthManager = OAuth1Swift(
        consumerKey:    "CbE3BbqhqwxNbRdGCP5y2gDU2",
        consumerSecret: "PxQy9075tg4QSZsLZNX3wwXEkG5fyuhtrAlNjM868sYRi6BCU8",
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl:    "https://api.twitter.com/oauth/authorize",
        accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
    )
    
    private var idForLoggedInUser: String?
    var screenNameForLoggedInUser: String?
    
    func authorizeTwitter(completion: (Result<Void>) -> Void) {
        if let callbackURL = NSURL(string: self.callbackURL) {
            
            let success = { (credential: OAuthSwiftCredential, response: NSURLResponse?, parameters: [String:String]) in
                self.idForLoggedInUser = parameters["user_id"]
                self.screenNameForLoggedInUser = parameters["screen_name"]
                completion(.Success())
            }
            
            let failure = { (error:NSError) in
                completion(.Failure(TwitterMiniError.AuthenticationFailure))
            }
            
            self.oauthManager.authorizeWithCallbackURL(callbackURL, success: success, failure: failure)
        } else {
            Qu.Main {
                completion(.Failure(TwitterMiniError.AuthenticationFailure))
            }
        }
    }
    
    func fetchTimeline(completion: (Result<[[String:AnyObject]]?>) -> Void) {
        if let idForLoggedInUser = self.idForLoggedInUser {
            
            let homeTimelineEndpoint = "statuses/home_timeline.json"
            let homeTimelineURL = "\(self.twitterBaseURL)\(homeTimelineEndpoint)?user_id=\(idForLoggedInUser)"
            
            self.oauthManager.client.get(homeTimelineURL, success: { data, response in
                completion(self.serializeTimelineData(data))
                }, failure: { error in
                    completion(.Failure(TwitterMiniError.RequestFailure))
            })
        } else {
            completion(.Failure(TwitterMiniError.AuthenticationFailure))
        }
    }
    
    // MARK: Helpers
    
    func serializeTimelineData(data:NSData) -> Result<[[String:AnyObject]]?> {
        do {
            let dataObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String:AnyObject]]
            return .Success(dataObject)
        } catch {
            return .Failure(TwitterMiniError.RequestFailure)
        }
    }
    
}
