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
                DispatchQueue.main.async(execute: { 
                    if error != nil {
                        let gtfsManagerAlert = UIAlertController(title: "GTFS Manager Error",
                            message: error?.description,
                            preferredStyle: .alert)
                        gtfsManagerAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(gtfsManagerAlert, animated: true, completion: nil)
                    }else{
                        // tela de progresso
                        SVProgressHUD.showProgress(-1, status: "Calculando arquvos")
                        SVProgressHUD.setDefaultMaskType(.black)
                        SVProgressHUD.setDefaultStyle(.dark)
                    }
                })
                }, reportProgress: { progress, total in
                    let p = Float(progress/total)
                    DispatchQueue.main.async(execute: {
                        if p.isNaN {
                            SVProgressHUD.showProgress(-1, status: "Calculando arquvos...")
                            SVProgressHUD.setDefaultMaskType(.black)
                            SVProgressHUD.setDefaultStyle(.dark)
                        }
                        else if p >= 1 { SVProgressHUD.dismiss() }
                        else {
                            SVProgressHUD.showProgress(p, status: "Processando; \(Int(p*100))%")
                            SVProgressHUD.setDefaultMaskType(.black)
                            SVProgressHUD.setDefaultStyle(.dark)
                        }
                    })
            })
        }
        
        SPTransAPI.shared.authenticate { (result) in
            if result == true {
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.green]
                self.navigationItem.title = "Online"
            }else{
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.red]
                self.navigationItem.title = "Offline"
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.title = "Home"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
        
    }


    //UITableView Methods
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewEntries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "home_cell", for: indexPath)
        cell.textLabel?.text = self.tableViewEntries[indexPath.row]
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let entry = self.tableViewEntries[indexPath.row]
        switch entry {
        case "buscar linha":
            self.performSegue(withIdentifier: "buscar_linha", sender: tableView.cellForRow(at: indexPath))
            break
        case "teste mapa":
            self.performSegue(withIdentifier: "testar_mapa", sender: tableView.cellForRow(at: indexPath))
            break
        default:
            break
        }
        
    }
    
}

