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
        
        GTFSManager.sharedInstance.downloadGTFS { (finished) in
            print("Finished downloading bundle files")
            for (key, value) in GTFSManager.sharedInstance.fileNames {
//                GTFSParser.sharedInstance.parseCSV(value!, completion: { (result) in
                    switch key{
                    case "agency":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSAgency.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSAgency(value: collection)
                        })
                        break
                    case "calendar":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSCalendar.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSCalendar(value: collection)
                        })
                        break
                    case "fare_attributes":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSFareAttribute.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSFareAttribute(value: collection)
                        })
                        break
                    case "fare_rules":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSFareRule.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSFareRule(value: collection)
                        })
                        break
                    case "frequencies":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSFrequency.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSFrequency(value: collection)
                        })
                        break
                    case "routes":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSRoute.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSRoute(value: collection)
                        })
                        break
                    case "shapes":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSShape.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSShape(value: collection)
                        })
                        break
                    case "stop_times":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSStopTime.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSStopTime(value: collection)
                        })
                        break
                    case "stops":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSStop.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSStop(value: collection)
                        })
                        break
                    case "trips":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSTrip.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSTrip(value: collection)
                        })
                        break
                    case "transfers":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSTransfer.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSTransfer(value: collection)
                        })
                        break
                    case "calendar_dates":
//                        GTFSParser.sharedInstance.parse(result!, className: GTFSCalendarDates.self)
                        GTFSParser.sharedInstance.parseWithCheese(value!, returnObject: { (collection) -> Object in
                            return GTFSCalendarDates(value: collection)
                        })
                        break
                    default:
                        break
                    }
//                })
            }
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
            print("ooops something is wrong")
        }
        
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

