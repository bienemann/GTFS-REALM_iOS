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

class TesteLinhaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView : UITableView?
    @IBOutlet weak var searchBar : UISearchBar?
    
    var searchDataSource : Array<LineModel> = Array()
    
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
        cell.textLabel?.text = line.currentName()
        cell.detailTextLabel?.text = "\(line.lineIDNumber)-\(line.lineIDType)"
        return cell
    }
    
    //SearchBar Delegte
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SVProgressHUD.showWithStatus("buscando linhas")
        
        SPTransAPI.shared.buscarLinha(searchBar.text!) { (result) in
            if result != nil{
                self.searchDataSource.removeAll()
                self.searchDataSource.appendContentsOf(result!)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView?.reloadData()
                SVProgressHUD.dismiss()
            })
            
        }
    }
}
