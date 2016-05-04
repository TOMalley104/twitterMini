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
import Genome
import PureJsonSerializer

// MARK: Status/User Objects

struct TwitterStatus : MappableObject {
    let createdAt: String
    let text: String
    let user: TwitterUser
    let likes: Int
    let retweets: Int
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
    
    init(map: Map) throws {
        self.createdAt = try map.extract("created_at")
        self.text = try map.extract("text")
        self.likes = try map.extract("favorite_count")
        self.retweets = try map.extract("retweet_count")
        // FIXME: prevents statuses that don't have a mediaURL from getting created
        try self.mediaURL <~ map["extended_entities.media"].transformFromJson { (json: Json) -> String? in
            return json.arrayValue?.first?["media_url_https"]?.stringValue ?? ""
        } 
        self.user = try TwitterUser(map: map)
    }
}

struct TwitterUser : MappableObject {
    let name: String
    let screenName: String
    let profileImageURL: String
    
    init(map: Map) throws {
        self.name = try map.extract("user.name")
        self.screenName = try map.extract("user.screen_name")
        self.profileImageURL = try map.extract("user.profile_image_url_https")
    }
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
        var newStatuses = [TwitterStatus]()
        for statusDictionary in rawStatuses {
            do {
                let status = try TwitterStatus(js: statusDictionary)
                newStatuses.append(status)
            } catch {
                // genome prints its own errors so no need...
            }
        }
        return newStatuses
    }
}
