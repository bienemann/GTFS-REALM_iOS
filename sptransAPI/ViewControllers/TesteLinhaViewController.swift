//
//  TesteLinhaViewController.swift
//  sptransAPI
//
//  Created by Allan Denis Martins on 7/29/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class TesteLinhaViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        SPTransAPI.shared.buscarLinha("5119") { (result) in
            if result != nil{
                for line in result! {
                    print(line.currentName())
                }
            }
        }
    }
}