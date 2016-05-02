//
//  Status.swift
//  twitterMini
//
//  Created by Tom O'Malley on 5/2/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import OAuthSwift

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
    static let sharedClient = TwitterAPIClient()
    
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
    
    func authorizeTwitter(completion: (success: Bool) -> Void){
        if let callbackURL = NSURL(string: callback) {
            oauthManager.authorizeWithCallbackURL( callbackURL, success: {
                credential, response, parameters in
                print("Authentication Success, userID:\(parameters["user_id"])")
                self.idForLoggedInUser = parameters["user_id"]
                completion(success:true)
                }, failure: { error in
                    print("Authentication Error: \(error.localizedDescription)")
                    completion(success:false)
                }
            )
        }
    }

    func fetchTimeline(completion: (rawStatuses: [[String:AnyObject]]?, error: NSError?) -> Void){
        if let idForLoggedInUser = idForLoggedInUser{
            let homeTimelineEndpoint = "statuses/home_timeline.json"
            let homeTimelineURL = "\(twitterBaseURL)\(homeTimelineEndpoint)?user_id=\(idForLoggedInUser)"
            print("hitting \(homeTimelineURL)")
            oauthManager.client.get(homeTimelineURL, success: { data, response in
                print("Fetch Home Timeline Success")
                do {
                    let dataObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String:AnyObject]]
                    completion(rawStatuses: dataObject, error: nil)
                } catch {
                    print("Error Serializing JSON: \(error)")
                    completion(rawStatuses: nil, error: error as NSError)
                }
                }, failure: { error in
                    print("Fetch Home Timeline Error:\(error.localizedDescription)")
                    completion(rawStatuses: nil, error: error)
            })
        } else {
            print("user is not logged in...")
            // FIXME: use constants
            let error = NSError(domain: "Tom's Domain", code: 420, userInfo: [NSLocalizedDescriptionKey:"There is no authenticated user."])
            completion(rawStatuses:nil, error: error)
        }
    }
}

// MARK: Data Manager

class TwitterDataManager {
    static let sharedManager = TwitterDataManager()
    let twitter = TwitterAPIClient.sharedClient // maybe make just the OAuth1Swift a singleton and use that to init any API instances?
    var statuses = [TwitterStatus]()
    
    func authorize(completion:(success: Bool) -> Void){
        twitter.authorizeTwitter { success in
            completion(success: success)
        }
    }
    
    func populateStatuses(completion: (NSError?) -> Void){
        twitter.fetchTimeline { rawStatuses, error in
            if let error = error {
                completion(error)
            } else {
                // FIXME: use genome
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
                completion(nil)
            }
        }
    }
}




