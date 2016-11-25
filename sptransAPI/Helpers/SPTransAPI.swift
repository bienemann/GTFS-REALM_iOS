//
//  SPTransAPI.swift
//  sptransAPI
//
//  Created by resource on 7/29/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class SPTransAPI : NSObject {
    
    static let shared = SPTransAPI()
    let apiKey = "e86972bad776dfaaba882db93230bf1b4745a4c9d21ddfcd15c71106d2fa6f79"
    let baseURL = "http://api.olhovivo.sptrans.com.br/v0"
    
    func authenticate(_ result:@escaping (_ result: Bool) -> Void) {
        let requestURL = "\(baseURL)/Login/Autenticar?token=\(apiKey)"
        Alamofire.request(requestURL).responseJSON { response in
            if response.result.isSuccess{
                result(response.result.value as! Bool)
            }else{ result(false) }
        }
    }

}
