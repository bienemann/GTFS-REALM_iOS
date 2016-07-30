//
//  TesteLinhaViewController.swift
//  sptransAPI
//
//  Created by Allan Denis Martins on 7/29/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import UIKit

class TesteLinhaViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SPTransAPI.shared.buscarLinha("5119") { (response) in
            print(response)
        }
        
    }
    
}
