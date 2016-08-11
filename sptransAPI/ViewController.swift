//
//  ViewController.swift
//  sptransAPI
//
//  Created by resource on 7/29/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!

    let tableViewEntries : [String] = ["buscar linha"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if GTFSManager.isDatabasePopulated() == true {
            print("dtabase already up to date")
        }else{
            print("downloading files and populating database")
            GTFSManager.downloadAndParseDocuments({ (error) in
                dispatch_async(dispatch_get_main_queue(), { 
                    if error != nil {
                        let gtfsManagerAlert = UIAlertController(title: "GTFS Manager Error",
                            message: error?.description,
                            preferredStyle: .Alert)
                        gtfsManagerAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        self.presentViewController(gtfsManagerAlert, animated: true, completion: nil)
                    }
                })
            })
        }
        
        SPTransAPI.shared.authenticate { (result) in
            if result == true {
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.greenColor()]
                self.navigationItem.title = "Online"
            }else{
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.redColor()]
                self.navigationItem.title = "Offline"
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.title = "Home"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        
        if segue.identifier == "open_test"{
        
        }
    }


    //UITableView Methods
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewEntries.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("home_cell", forIndexPath: indexPath)
        cell.textLabel?.text = self.tableViewEntries[indexPath.row]
        return cell
        
    }

    
}

