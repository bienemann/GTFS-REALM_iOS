//
//  TesteLinhaViewController.swift
//  sptransAPI
//
//  Created by Allan Denis Martins on 7/29/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Dispatch
import RealmSwift

class TesteLinhaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView : UITableView?
    @IBOutlet weak var searchBar : UISearchBar?
    
    var searchDataSource : Array<GTFSTrip> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Table View Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchDataSource.count > 0 ? self.searchDataSource.count + 1 : 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("line_cell", forIndexPath: indexPath)
        
        if indexPath.row < self.searchDataSource.count {
            let line = self.searchDataSource[indexPath.row]
            cell.textLabel?.text = line.trip_headsign!
            cell.detailTextLabel?.text = line.route_id
        }else{
            cell.textLabel?.text = "ver todas no mapa"
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("test_route", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "test_route" {
            let vc = segue.destinationViewController as! TestMapViewController
            
            let selectedIndex = self.tableView?.indexPathForCell(sender as! UITableViewCell)
            
            
            if selectedIndex?.row == self.searchDataSource.count {
                for trip in self.searchDataSource{
                    vc.lines.append(GTFSTripPolyline(trip: trip))
                }
            }else{
                let trip = self.searchDataSource[selectedIndex!.row]
                vc.lines.append(GTFSTripPolyline(trip: trip))
            }   
        }
    }
    
    //SearchBar Delegte
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SVProgressHUD.showWithStatus("buscando linhas")
        
        let trips = GTFSQuery.tripsContaining(searchBar.text!)
        
        self.searchDataSource.removeAll()
        if trips.count > 0 {
            print(trips)
            self.searchDataSource.appendContentsOf(trips)
        }else {
            //tratar sem resultados
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView?.reloadData()
            SVProgressHUD.dismiss()
        })
        
    }
}
