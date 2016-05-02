//
//  Status.swift
//  twitterMini
//
//  Created by Tom O'Malley on 5/2/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation

struct TwitterStatus {
    let createdAt : String
    let hashtags : [String]
    let text : String
    let user : TwitterUser
    let likes : Int
    let retweets : Int
    //TODO: deal with media (["extendedEntities"]["media"]["media_url_https"])
}

struct TwitterUser {
    let screenName : String
    let name : String
    let profileImageURL : String
}
