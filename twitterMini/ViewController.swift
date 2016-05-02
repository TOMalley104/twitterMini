//
//  ViewController.swift
//  twitterMini
//
//  Created by Tom O'Malley on 5/2/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController {
    
    let twitter = TwitterAPIClient.sharedClient
    let twitterSignInButton = UIButton()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTwitterButton()
        // we need to tell it who is presenting the safariVC for authorization
        twitter.oauthManager.authorize_url_handler = SafariURLHandler(viewController: self)
    }
    
    // MARK: Actions
    
    func authorizeTapped() {
        twitter.authorizeTwitter { (success) in
            if success {
                // auto fetch statuses?
            } else {
                // present error alert
            }
        }
    }
    
    // MARK: Helpers
    
    func setupTwitterButton(){
        twitterSignInButton.backgroundColor = UIColor.blackColor()
        view.addSubview(twitterSignInButton)
        twitterSignInButton.translatesAutoresizingMaskIntoConstraints = false
        twitterSignInButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        twitterSignInButton.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        twitterSignInButton.setTitle("Authorize Twitter", forState: .Normal)
        twitterSignInButton.addTarget(self, action: #selector(authorizeTapped), forControlEvents: .TouchUpInside)
    }
}
