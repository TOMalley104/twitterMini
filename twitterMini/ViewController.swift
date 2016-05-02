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
                self.twitterSignInButton.hidden = true
                // load status w/ indicator
                self.twitter.fetchTimeline({ (error) in
                    if let error = error {
                        self.presentErrorAlert(error.localizedDescription)
                    } else {
                        // dismiss indicator, show tableview of statuses
                    }
                })
            } else {
                self.presentErrorAlert()
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
    
    func presentErrorAlert(message:String = "Something went wrong. Sorry :("){
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
