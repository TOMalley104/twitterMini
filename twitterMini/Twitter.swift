//
//  Status.swift
//  twitterMini
//
//  Created by Tom O'Malley on 5/2/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import OAuthSwift
import Intrepid

// MARK: Status/User Objects

struct TwitterStatus {
    let createdAt: String
    let text: String
    let user: TwitterUser
    let likes: String
    let retweets: String
    //TODO: deal with media (["extendedEntities"]["media"]["media_url_https"])
}

struct TwitterUser {
    let screenName: String
    let name: String
    let profileImageURL: String
}

// MARK: API Client

class TwitterAPIClient {
    let twitterBaseURL = "https://api.twitter.com/1.1/"
    let callback = "twittestIntrepid://"
    
    let oauthManager = OAuth1Swift(
        consumerKey:    "CbE3BbqhqwxNbRdGCP5y2gDU2",
        consumerSecret: "PxQy9075tg4QSZsLZNX3wwXEkG5fyuhtrAlNjM868sYRi6BCU8",
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl:    "https://api.twitter.com/oauth/authorize",
        accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
    )
    
    private var idForLoggedInUser: String?
    
    // FIXME: change completion to error
    func authorizeTwitter(completion: (Result<Void>) -> Void) {
        if let callbackURL = NSURL(string: callback) {

            let success = { (credential: OAuthSwiftCredential, response: NSURLResponse?, parameters: [String:String]) in
                print("Authentication Success, userID:\(parameters["user_id"])")
                self.idForLoggedInUser = parameters["user_id"]
                completion(.Success())
            }
            
            let failure = { (error:NSError) in
                print("Authentication Error: \(error.localizedDescription)")
                completion(.Failure(error))
            }
            
            oauthManager.authorizeWithCallbackURL(callbackURL, success: success, failure: failure)
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                // FIXME: use application error
                let error = NSError(domain: "Tom's Domain", code: 420, userInfo: [NSLocalizedDescriptionKey:"Callback URL is invalid."])
                completion(.Failure(error))
            }
        }
    }
    
    func fetchTimeline(completion: (Result<[[String:AnyObject]]?>) -> Void) {
        if let idForLoggedInUser = idForLoggedInUser{
            
            let homeTimelineEndpoint = "statuses/home_timeline.json"
            let homeTimelineURL = "\(twitterBaseURL)\(homeTimelineEndpoint)?user_id=\(idForLoggedInUser)"
            
            oauthManager.client.get(homeTimelineURL, success: { data, response in
                completion(self.handleTimelineData(data))
                }, failure: { error in
                    completion(.Failure(error))
            })
            
        } else {
            print("user is not logged in...")
            // FIXME: use application error
            let error = NSError(domain: "Tom's Domain", code: 420, userInfo: [NSLocalizedDescriptionKey:"There is no authenticated user."])
            completion(.Failure(error))
        }
    }
    
    // MARK: Helpers
    
    func handleTimelineData(data:NSData) -> Result<[[String:AnyObject]]?> {
        do {
            let dataObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String:AnyObject]]
            return .Success(dataObject)
        } catch {
            return .Failure(error)
        }
    }

}

// MARK: Data Manager

class TwitterDataManager {
    static let sharedManager = TwitterDataManager()
    
    private let twitter = TwitterAPIClient()
    var statuses = [TwitterStatus]()
    
    func authorize(completion:(Result<Void>) -> Void) {
        twitter.authorizeTwitter { success in
            completion(.Success())
        } // FIXME: pass error through
    }
    
    func populateStatuses(completion: (Result<Void>) -> Void) {
        self.twitter.fetchTimeline { result in
            if let error = result.error {
                completion(.Failure(error))
            } else {
                // FIXME: use genome
                if let rawStatuses = result.value {
                    for statusDictionary in rawStatuses ?? [] {
                        if let createdAt = statusDictionary["created_at"] as? String,
                            let text = statusDictionary["text"] as? String,
                            let likes = statusDictionary["favorite_count"] as? Int,
                            let retweets = statusDictionary["retweet_count"] as? Int,
                            let userDictionary = statusDictionary["user"] as? [String: AnyObject],
                            let name = userDictionary["name"] as? String,
                            let screenName = userDictionary["screen_name"] as? String,
                            let profileImageURL = userDictionary["profile_image_url_https"] as? String {
                            
                            let user = TwitterUser(screenName: screenName, name: name, profileImageURL: profileImageURL)
                            let status = TwitterStatus(createdAt: createdAt, text: text, user: user, likes: "\(likes)", retweets: "\(retweets)")
                            self.statuses.append(status)
                        }
                    }
                }
                completion(.Success())
            }
        }
    }
}




