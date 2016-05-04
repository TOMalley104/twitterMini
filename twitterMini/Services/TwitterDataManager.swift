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
    var mediaURL: String?
    
    var timeSinceCreation: String? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        if let createdAtDate = dateFormatter.dateFromString(self.createdAt) {
            if NSDate().minutesFrom(createdAtDate) < 59 {
                return "\(NSDate().minutesFrom(createdAtDate))m"
            } else if NSDate().hoursFrom(createdAtDate) < 24 {
                return "\(NSDate().hoursFrom(createdAtDate))h"
            } else {
                return "\(NSDate().daysFrom(createdAtDate))d"
            }
        }
        return nil
    }
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
    var userScreenName: String?
    
    func authorize(completion: (Result<Void>) -> Void) {
        self.twitter.authorizeTwitter { result in
            self.userScreenName = self.twitter.screenNameForLoggedInUser
            completion(result)
        }
    }
    
    func populateStatuses(completion: (Result<Void>) -> Void) {
        self.twitter.fetchTimeline { result in
            if let error = result.error {
                completion(.Failure(error))
            } else {
                if let value = result.value,
                    let rawStatuses = value {
                    self.statuses = self.createStatuses(fromDictionaries: rawStatuses)
                }
                completion(.Success())
            }
        }
    }
    
    func createStatuses(fromDictionaries rawStatuses: [[String:AnyObject]]) -> [TwitterStatus] {
        // FIXME: use genome
        var newStatuses = [TwitterStatus]()
        for statusDictionary in rawStatuses {
            if let createdAt = statusDictionary["created_at"] as? String,
                let text = statusDictionary["text"] as? String,
                let likes = statusDictionary["favorite_count"] as? Int,
                let retweets = statusDictionary["retweet_count"] as? Int,
                let userDictionary = statusDictionary["user"] as? [String: AnyObject],
                let name = userDictionary["name"] as? String,
                let screenName = userDictionary["screen_name"] as? String,
                let profileImageURL = userDictionary["profile_image_url_https"] as? String {
                
                var mediaURL : String?
                var strippedText : String?

                if let mediaDictionaries = statusDictionary["extended_entities"]?["media"] as? [[String:AnyObject]],
                    let firstMediaDictionary = mediaDictionaries.first,
                    let urlToStrip = firstMediaDictionary["url"] as? String,
                    let actualMediaURL = firstMediaDictionary["media_url_https"] as? String {
                    mediaURL = actualMediaURL
                    strippedText = text.stringByReplacingOccurrencesOfString(urlToStrip, withString: "")
                }
                
                let user = TwitterUser(screenName: screenName, name: name, profileImageURL: profileImageURL)
                let status = TwitterStatus(createdAt: createdAt, text: strippedText ?? text, user: user, likes: "\(likes)", retweets: "\(retweets)", mediaURL:mediaURL ?? nil)
                newStatuses.append(status)
            }
        }
        return newStatuses
    }
}
