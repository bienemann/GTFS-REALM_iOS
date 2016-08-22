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
        return realm.objects(GTFSTrip.self).filter("route_id CONTAINS[c] %@ OR trip_headsign CONTAINS[c] %@",
                                                   term,
                                                   term)
    }
    
    class func shapesForTrip(trip: GTFSTrip) -> Results<GTFSShape> {
        let realm = try! Realm()
        return realm.objects(GTFSShape.self)
            .filter("shape_id == %d", trip.shape_id.value!)
            .sorted("shape_pt_sequence", ascending: true)
    }
    
}