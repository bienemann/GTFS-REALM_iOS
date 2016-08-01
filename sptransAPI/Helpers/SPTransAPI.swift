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
    let baseURL = "http://api.olhovivo.sptrans.com.br/v1"
    
    func authenticate(result:(result: Bool) -> Void) {
        let requestURL = "\(baseURL)/Login/Autenticar?token=\(apiKey)"
        Alamofire.request(.POST, requestURL).responseJSON { response in
            result(result: response.result.value as! Bool)
        }
    }
    
    func loadDetails(lineID : Int){
        let requestURL = "\(baseURL)/Linha/CarregarDetalhes?codigoLinha=\(lineID)"
        Alamofire.request(.GET, requestURL).responseJSON { (response) in
            print(response)
        }
    }
    
    func buscarLinha(searchTerm: String, completion: (result : Array<LineModel>?) -> Void){
        let requestURL = "\(baseURL)/Linha/Buscar?termosBusca=\(searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)"
        Alamofire.request(.GET, requestURL).responseJSON { (response) in
            switch response.result.isSuccess{
            case true:
                
                guard let JSON = response.result.value as! NSArray? else {
                    completion(result: nil)
                    return
                }
                
                var lines : Array<LineModel> = Array()
                for lineDict in JSON {
                    guard let line = Mapper<LineModel>().map(lineDict) else {
                        continue
                    }
                    lines.append(line)
                }
                completion(result: lines)
                
                break
            case false:
                completion(result: nil)
                break
            }
        }
    }
    
}
