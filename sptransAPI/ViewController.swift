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
        
        let realm = try! Realm()
        let agencyResult = realm.objects(GTFSAgency.self).filter("agency_name = 'SPTRANS'")
        if agencyResult.count > 0 {
            let agency = agencyResult.first!
            if agency.agency_name == "SPTRANS" {
                print("SPTRANS ja existe no banco")
            }else{
                print("ha algo no banco mas não é sptrans")
            }
        }else{
            print("SPTRANS não existe no banco, criando agora.")
            GTFSParser.sharedInstance.parseAgency("http://127.0.0.1:8080/agency.txt")
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
            
//            let cell = sender as! UITableViewCell
//            
//            switch tableViewEntries[(self.tableView.indexPathForCell(cell)?.row)!] {
//            case "buscar linha":
//                
//                let viewController = segue.destinationViewController as! TesteLinhaViewController
//                viewController.title = "teste buscar linha"
//                break
//                
//            default:
//                break
//            }
        
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

