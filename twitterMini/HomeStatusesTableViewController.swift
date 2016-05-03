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
    
    let cellIdentifier = "twitterCell"
    let dataManager = TwitterDataManager.sharedManager
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: bar button for log in / out
        let nib = UINib(nibName: "TwitterTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 20
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.authorizeTwitter()
    }
    
    // MARK: Twitter Authentication / Fetching
    
    func authorizeTwitter() {
        self.dataManager.authorize { result in
            if result.isSuccess {
                self.populateStatuses()
            } else if let error = result.error as? NSError {
                self.presentErrorAlert(error.description)
            }
        }
    }
    
    func populateStatuses() {
        self.dataManager.populateStatuses({ result in
            if let error = result.error as? NSError {
                self.presentErrorAlert(error.localizedDescription)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TwitterTableViewCell
        cell.status = self.dataManager.statuses[indexPath.row]
        return cell
    }
    
    // MARK: Helpers
    
    // FIXME: make this take an tMiniError
    func presentErrorAlert(message: String = "Something went wrong. Sorry :("){
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
