//
//  ViewController.swift
//  sptransAPI
//
//  Created by resource on 7/29/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!

    let tableViewEntries : [String] = ["buscar linha", "teste mapa", "linhas que passam aqui"]
    
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
                    }else{
                        // tela de progresso
                        SVProgressHUD.showProgress(-1, status: "Calculando arquvos")
                        SVProgressHUD.setDefaultMaskType(.Black)
                        SVProgressHUD.setDefaultStyle(.Dark)
                    }
                })
                }, reportProgress: { progress, total in
                    let p = Float(progress/total)
                    dispatch_async(dispatch_get_main_queue(), {
                        if p.isNaN {
                            SVProgressHUD.showProgress(-1, status: "Calculando arquvos...")
                            SVProgressHUD.setDefaultMaskType(.Black)
                            SVProgressHUD.setDefaultStyle(.Dark)
                        }
                        else if p >= 1 { SVProgressHUD.dismiss() }
                        else {
                            SVProgressHUD.showProgress(p, status: "Processando; \(Int(p*100))%")
                            SVProgressHUD.setDefaultMaskType(.Black)
                            SVProgressHUD.setDefaultStyle(.Dark)
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let entry = self.tableViewEntries[indexPath.row]
        switch entry {
        case "buscar linha":
            self.performSegueWithIdentifier("buscar_linha", sender: tableView.cellForRowAtIndexPath(indexPath))
            break
        case "teste mapa":
            self.performSegueWithIdentifier("testar_mapa", sender: tableView.cellForRowAtIndexPath(indexPath))
            break
        default:
            break
        }
        
    }
    
}

