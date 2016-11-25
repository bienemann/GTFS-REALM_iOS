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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchDataSource.count > 0 ? self.searchDataSource.count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "line_cell", for: indexPath)
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "test_route", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "test_route" {
            let vc = segue.destination as! TestMapViewController
            
            let selectedIndex = self.tableView?.indexPath(for: sender as! UITableViewCell)
            
            
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SVProgressHUD.show(withStatus: "buscando linhas")
        
        let trips = GTFSQuery.tripsContaining(searchBar.text!)
        
        self.searchDataSource.removeAll()
        if trips.count > 0 {
            print(trips)
            self.searchDataSource.append(contentsOf: trips)
        }else {
            //tratar sem resultados
        }
        
        DispatchQueue.main.async(execute: {
            self.tableView?.reloadData()
            SVProgressHUD.dismiss()
        })
        
    }
}
