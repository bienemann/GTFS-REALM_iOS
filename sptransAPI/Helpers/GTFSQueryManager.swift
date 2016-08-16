//
//  GTFSQueryManager.swift
//  sptransAPI
//
//  Created by resource on 8/12/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSQueryManager {
    
    class func selectTripsContaining(term: String) -> Results<GTFSTrip>  {
        
        let realm = try! Realm()
        let query1 = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "route_id"),
                                           rightExpression: NSExpression(format: "%@", term),
                                           modifier: .DirectPredicateModifier,
                                           type: .ContainsPredicateOperatorType,
                                           options: .CaseInsensitivePredicateOption)
        let query2 = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "trip_headsign"),
                                           rightExpression: NSExpression(format: "%@", term),
                                           modifier: .DirectPredicateModifier,
                                           type: .ContainsPredicateOperatorType,
                                           options: .CaseInsensitivePredicateOption)
        let compoundQuery = NSCompoundPredicate(orPredicateWithSubpredicates: [query1, query2])
        
        return realm.objects(GTFSTrip.self).filter(compoundQuery)
        
    }
    
    class func shapesForTrip(trip: GTFSTrip) -> Results<GTFSShape> {
        
        let realm = try! Realm()
        let query = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "shape_id"),
                                          rightExpression: NSExpression(format: "%d", trip.shape_id.value!),
                                          modifier: .DirectPredicateModifier,
                                          type: .EqualToPredicateOperatorType,
                                          options: .CaseInsensitivePredicateOption)
        return realm.objects(GTFSShape.self).filter(query).sorted("shape_pt_sequence", ascending: true)
        
    }
    
}