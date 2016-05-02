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
    let createdAt : String
    let text : String
    let user : TwitterUser
    let likes : String
    let retweets : String
    //TODO: deal with media (["extendedEntities"]["media"]["media_url_https"])
}

struct TwitterUser {
    let screenName : String
    let name : String
    let profileImageURL : String
}

// MARK: API Client

class TwitterAPIClient {
    static let sharedClient = TwitterAPIClient()
    
    let twitterBaseURL = "https://api.twitter.com/1.1/"
    //    let key = "CbE3BbqhqwxNbRdGCP5y2gDU2"
    //    let secret = "PxQy9075tg4QSZsLZNX3wwXEkG5fyuhtrAlNjM868sYRi6BCU8"
    let callback = "twittestIntrepid://"
    
    let oauthManager = OAuth1Swift(
        consumerKey:    "CbE3BbqhqwxNbRdGCP5y2gDU2",
        consumerSecret: "PxQy9075tg4QSZsLZNX3wwXEkG5fyuhtrAlNjM868sYRi6BCU8",
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl:    "https://api.twitter.com/oauth/authorize",
        accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
    )
    private var idForLoggedInUser : String?

    func authorizeTwitter(completion:(success:Bool) -> Void){
        oauthManager.authorizeWithCallbackURL( NSURL(string: callback)!, success: {
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
    
    func fetchTimeline(completion:(error:NSError?)->Void){
        if let idForLoggedInUser = idForLoggedInUser{
            let homeTimelineEndpoint = "statuses/home_timeline.json"
            let homeTimelineURL = "\(twitterBaseURL)\(homeTimelineEndpoint)?user_id=\(idForLoggedInUser)"
            print("hitting \(homeTimelineURL)")
            oauthManager.client.get(homeTimelineURL, success: { (data, response) in
                print("Fetch Home Timeline Success")
                do{
                    let dataObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])

                    // TODO: move this code into a datastore, pass dataObject via completion
                    
//                    // STATUS
//                    if let statusDictionary = dataObject.firstObject as? [String:AnyObject],
//                        let createdAt = statusDictionary["created_at"] as? String,
//                        let text = statusDictionary["text"] as? String,
//                        let likes = statusDictionary["favorite_count"] as? String,
//                        let retweets = statusDictionary["retweet_count"] as? String {
//                        print(createdAt)
//                        print(text, likes, retweets)
//                        
//                        // USER
//                        if let userDictionary = statusDictionary["user"] as? [String:AnyObject],
//                            let name = userDictionary["name"] as? String,
//                            let screenName = userDictionary["screen_name"] as? String,
//                            let profileImageURL = userDictionary["profile_image_url_https"] as? String {
//                            
//                            let user = TwitterUser(screenName:screenName, name:name, profileImageURL:profileImageURL)
//                            let status = TwitterStatus(createdAt:createdAt, text:text, user:user, likes:likes, retweets:likes)
//                            print(status)
//                        }
//                    }
                } catch {
                    print("Error Serializing JSON: \(error)")
                    completion(error:error as NSError)
                }
                }, failure: { (error) in
                    print("Fetch Home Timeline Error:\(error.localizedDescription)")
                    completion(error:error)
            })
        } else {
            print("user is not logged in...")
            let error = NSError(domain: "Tom's Domain", code: 420, userInfo: [NSLocalizedDescriptionKey:"There is no authenticated user."])
            completion(error: error)
        }
    }
}
