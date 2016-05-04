//
//  ViewController.swift
//  twitterMini
//
//  Created by Tom O'Malley on 5/2/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import UIKit
import OAuthSwift

class HomeStatusesTableViewController : UITableViewController {
    
    let mediaCellIdentifier = "twitterMediaCell"
    let textCellIdentifier = "twitterTextCell"
    let dataManager = TwitterDataManager.sharedManager
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "TwitterMediaTableViewCell", bundle: nil), forCellReuseIdentifier: mediaCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "TwitterTextTableViewCell", bundle: nil), forCellReuseIdentifier: textCellIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100 
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.authorizeTwitter()
    }
    
    // MARK: Twitter Authentication / Fetching
    
    func authorizeTwitter() {
        self.dataManager.authorize { result in
            if result.isSuccess {
                self.title = self.dataManager.userScreenName
                self.populateStatuses()
            } else if let error = result.error as? TwitterMiniError {
                self.presentErrorAlert(error)
            }
        }
    }
    
    func populateStatuses() {
        self.dataManager.populateStatuses({ result in
            if let error = result.error as? TwitterMiniError {
                self.presentErrorAlert(error)
            } else {
                self.tableView.reloadData()
                print(self.dataManager.statuses)
            }
        })
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataManager.statuses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let status = self.dataManager.statuses[indexPath.row]
        if status.mediaURL != nil {
            let cell = tableView.dequeueReusableCellWithIdentifier(mediaCellIdentifier, forIndexPath: indexPath) as! TwitterMediaTableViewCell
            cell.status = status
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! TwitterTextTableViewCell
            cell.status = self.dataManager.statuses[indexPath.row]
            return cell
        }
    }
    
    // MARK: Helpers
    
    func presentErrorAlert(error: TwitterMiniError){
        let message: String
        switch error {
        case .AuthenticationFailure:
            message = "Authentication with Twitter failed. Try logging in again."
            break
        case .RequestFailure:
            message = "Authentication with Twitter failed. Try logging in again."
            break
        }
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
