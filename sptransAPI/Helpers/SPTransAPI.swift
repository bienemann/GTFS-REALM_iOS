//
//  SPTransAPI.swift
//  sptransAPI
//
//  Created by resource on 7/29/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import Alamofire

class SPTransAPI : NSObject {
    
    static let shared = SPTransAPI()
    let apiKey = "e86972bad776dfaaba882db93230bf1b4745a4c9d21ddfcd15c71106d2fa6f79"
    let baseURL = "http://api.olhovivo.sptrans.com.br/v0"
    
    func authenticate(result:(result: Bool) -> Void) {
        let requestURL = "\(baseURL)/Login/Autenticar?token=\(apiKey)"
        Alamofire.request(.POST, requestURL).responseJSON { response in
            result(result: response.result.value as! Bool)
        }
    }
    
}
