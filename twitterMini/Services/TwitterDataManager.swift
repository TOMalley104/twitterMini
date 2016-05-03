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

// MARK: Data Manager

class TwitterDataManager {
    static let sharedManager = TwitterDataManager()
    
    private let twitter = TwitterAPIClient()
    var statuses = [TwitterStatus]()
    
    func authorize(completion:(Result<Void>) -> Void) {
        self.twitter.authorizeTwitter { result in
            completion(result)
        }
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
