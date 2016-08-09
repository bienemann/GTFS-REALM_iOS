//
//  GTFSManager.swift
//  sptransAPI
//
//  Created by Allan Denis Martins on 8/3/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

//to-do: make this class more generic
class GTFSManager {
    
    static let sharedInstance = GTFSManager()
    
    let baseURL = "http://127.0.0.1:8080"
    var fileNames : Dictionary<String, String?> = ["agency": nil,
                                     "calendar": nil,
                                     "fare_attributes": nil,
                                     "fare_rules": nil,
                                     "frequencies": nil,
                                     "routes": nil,
                                     "shapes": nil,
                                     "stop_times": nil,
                                     "stops": nil,
                                     "trips": nil]
    
    class func isDatabasePopulated(populate populate: Bool = false) -> Bool{
        
        let realm = try! Realm()
        let agencyResult = realm.objects(GTFSAgency.self).filter("agency_name = 'SPTRANS'")
        if agencyResult.count > 0 { return true }
        else {
            if populate == true {
                GTFSManager.downloadAndParseDocuments()
            }
            return false
        }
        
    }
    
    class func downloadAndParseDocuments(){
        
        GTFSManager.sharedInstance.downloadGTFS { (finished) in
            print("Finished downloading GTFS files\nstarting parse\n")
            for (key, value) in GTFSManager.sharedInstance.fileNames {
                autoreleasepool({
                    var classType : GTFSBaseModel.Type = GTFSBaseModel.self
                    switch key{
                    case "agency":
                        classType = GTFSAgency.self
                        break
                    case "calendar":
                        classType = GTFSCalendar.self
                        break
                    case "fare_attributes":
                        classType = GTFSFareAttribute.self
                        break
                    case "fare_rules":
                        classType = GTFSFareRule.self
                        break
                    case "frequencies":
                        classType = GTFSFrequency.self
                        break
                    case "routes":
                        classType = GTFSRoute.self
                        break
                    case "shapes":
                        classType = GTFSShape.self
                        break
                    case "stop_times":
                        classType = GTFSStopTime.self
                        break
                    case "stops":
                        classType = GTFSStop.self
                        break
                    case "trips":
                        classType = GTFSTrip.self
                        break
                    case "transfers":
                        classType = GTFSTransfer.self
                        break
                    case "calendar_dates":
                        classType = GTFSCalendarDates.self
                        break
                    default:
                        break
                    }
                    print("parsing \(key)")
                    let parser = GTFSParser()
                    parser.parseDocument(value!, processValues: { (structure, line) -> GTFSBaseModel? in
                        return parser.parseLine(structure, line: line, model: classType)
                    })
                })
            }
        }
        
    }
    
    func hasAllFiles() -> Bool{
        for (_, value) in self.fileNames {
            if value == nil {return false}
        }
        return true
    }
    
    func downloadGTFS(finished: Bool -> Void){
        
        print("starting GTFS files download")
        
        let downloadQueue = dispatch_queue_create("com.mydlqueue", DISPATCH_QUEUE_CONCURRENT)
        let GTFSBundleDispatchGroup = dispatch_group_create()
        
        for (key, _) in self.fileNames {
            
            dispatch_group_enter(GTFSBundleDispatchGroup)
            
            let path = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
            let customPath = path.URLByAppendingPathComponent("GTFS/\(key).txt")
            if !NSFileManager.defaultManager().fileExistsAtPath("\(path.relativePath!)/GTFS") {
                try! NSFileManager.defaultManager().createDirectoryAtPath("\(path.URLByAppendingPathComponent("GTFS").relativePath!)", withIntermediateDirectories: true, attributes: nil)
            }
            
            Alamofire.download(.GET, "\(self.baseURL)/\(key).txt", destination: { (_, _) -> NSURL in
                return customPath
            }).response(completionHandler: { (request, resonse, data, error) in
                    self.fileNames.updateValue(customPath.relativePath!, forKey: key)
                    dispatch_group_leave(GTFSBundleDispatchGroup)
            })
            
        }
        
        dispatch_group_notify(GTFSBundleDispatchGroup, downloadQueue, {
            dispatch_async(dispatch_get_main_queue(), {
                finished(true)
                //to-do: testar se os arquivos foram baixados com sucesso
            })
        })
        
    }
    
}