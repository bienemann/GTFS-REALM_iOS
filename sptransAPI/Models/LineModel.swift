//
//  LineModel.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import ObjectMapper

class LineModel: Mappable {
    
    var lineUniqueID : Int!
    var roundabout : Bool!
    var lineIDNumber : String!
    var lineIDType : Int!
    var route : Int!
    var namePrimaryToSecondary : String!
    var nameSecondaryToPrimary : String!
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        lineUniqueID            <- map["CodigoLinha"]
        roundabout              <- map["Circular"]
        lineIDNumber            <- map["Letreiro"]
        lineIDType              <- map["Tipo"]
        route                   <- map["Sentido"]
        namePrimaryToSecondary  <- map["DenominacaoTPTS"]
        nameSecondaryToPrimary  <- map["DenominacaoTSTP"]
    }
    
    func currentName() -> String {
        if self.route == 1 {
            return self.namePrimaryToSecondary
        }else{
            return self.nameSecondaryToPrimary
        }
    }
    
}
