//
//  TwitterTableViewCell.swift
//  twitterMini
//
//  Created by Tom O'Malley on 5/2/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import UIKit

class TwitterTableViewCell : UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var textContentLabel: UILabel!
    
    var status: TwitterStatus?{
        didSet{
            userNameLabel.text = status?.user.name
            userScreenNameLabel.text = status?.user.screenName
            createdAtLabel.text = status?.createdAt
            textContentLabel.text = status?.text
        }
    }
    
    
    
}