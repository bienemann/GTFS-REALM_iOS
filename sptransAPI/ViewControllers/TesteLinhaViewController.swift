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
        return self.searchDataSource.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("line_cell", forIndexPath: indexPath)
        let line = self.searchDataSource[indexPath.row]
        cell.textLabel?.text = line.trip_headsign!
        cell.detailTextLabel?.text = line.route_id
        return cell
    }
    
    //SearchBar Delegte
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SVProgressHUD.showWithStatus("buscando linhas")
        
        let realm = try! Realm()
        
        let query1 = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "route_id"),
                                          rightExpression: NSExpression(format: "%@", searchBar.text!),
                                          modifier: .DirectPredicateModifier,
                                          type: .ContainsPredicateOperatorType,
                                          options: .CaseInsensitivePredicateOption)
        let query2 = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "trip_headsign"),
                                           rightExpression: NSExpression(format: "%@", searchBar.text!),
                                           modifier: .DirectPredicateModifier,
                                           type: .ContainsPredicateOperatorType,
                                           options: .CaseInsensitivePredicateOption)
        let compoundQuery = NSCompoundPredicate(orPredicateWithSubpredicates: [query1, query2])
        let trips = realm.objects(GTFSTrip.self).filter(compoundQuery)
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
