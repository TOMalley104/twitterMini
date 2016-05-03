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
    
    let dataManager = TwitterDataManager.sharedManager
    let twitterSignInButton = UIButton()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTwitterButton()
    }
    
    // MARK: Actions
    
    func authorizeTapped() {
        dataManager.authorize { result in
            if result.isSuccess {
                self.dataManager.populateStatuses({ result in
                    if let error = result.error {
                        self.presentErrorAlert((error as NSError).description)
                    } else {
                        print(self.dataManager.statuses)
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
    
    // FIXME: make this take an tMiniError
    func presentErrorAlert(message: String = "Something went wrong. Sorry :("){
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
