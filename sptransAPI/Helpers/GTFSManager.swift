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
    
    let baseURL = "http://10.77.126.132:8080"
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
    
    class func isDatabasePopulated() -> Bool{
        
        let realm = try! Realm()
        let agencyResult = realm.objects(GTFSAgency.self).filter("agency_name = 'SPTRANS'")
        if agencyResult.count > 0 { return true }
        else { return false }
        
    }
    
    class func downloadAndParseDocuments(_ error: @escaping (NSError?) -> Void, reportProgress: ((Double, Double)->Void)?) {
        
        GTFSManager.sharedInstance.downloadGTFS { (finished, err) in
            
            if !finished {
                error(err)
                return
            }
            
            var progressDict : Dictionary<String, Array<Double>> = [:]
        
            print("Finished downloading GTFS files\nstarting parse\n")
            for (key, value) in GTFSManager.sharedInstance.fileNames {
                autoreleasepool(invoking: {
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
                    
                    let parser = GTFSParser()
                    
                    let queue = DispatchQueue(label: key, attributes: DispatchQueue.Attributes.concurrent)
                    queue.async(execute: { 
                        parser.parseDocument(value!,
                            processValues: { (structure, line) -> GTFSBaseModel? in
                                return parser.parseLine(structure, line: line, model: classType)
                            },
                            progress: { (progress, total) in
                                progressDict.updateValue([progress, total], forKey: key)
                                if progressDict.count == GTFSManager.sharedInstance.fileNames.count {
                                    if reportProgress != nil {
                                        var totalProgress : Double = 0
                                        var totalGoal : Double = 0
                                        for v in progressDict.values {
                                            totalProgress += v[0]
                                            totalGoal += v[1]
                                        }
                                        DispatchQueue.main.async(execute: { 
                                            reportProgress!(totalProgress, totalGoal)
                                        })
                                    }
                                }else{
                                    DispatchQueue.main.async(execute: {
                                        reportProgress!(Double(0), Double(0))
                                    })
                                }
                        })
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
    
    func downloadGTFS(_ finished: @escaping (Bool, NSError?) -> Void){
        
        print("starting GTFS files download")
        
        let downloadQueue = DispatchQueue(label: "com.mydlqueue", attributes: DispatchQueue.Attributes.concurrent)
        let GTFSBundleDispatchGroup = DispatchGroup()
        var dirty : Bool = false
        var dlError : NSError? = nil
        
        for (key, _) in self.fileNames {
            
            GTFSBundleDispatchGroup.enter()
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let customPath = path.appendingPathComponent("GTFS/\(key).txt")
            if !FileManager.default.fileExists(atPath: "\(path.relativePath)/GTFS") {
                try! FileManager.default.createDirectory(atPath: "\(path.appendingPathComponent("GTFS").relativePath)", withIntermediateDirectories: true, attributes: nil)
            }
            
            let url = URLRequest(url: URL(string: "\(self.baseURL)/\(key).txt")!)
            Alamofire.download(url, to: { (_, _) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                return (customPath, [.createIntermediateDirectories, .removePreviousFile])
            }).response { response in
                if response.error != nil {
                    dirty = true
                    dlError = response.error as NSError?
                }
                self.fileNames.updateValue(customPath.relativePath, forKey: key)
                GTFSBundleDispatchGroup.leave()
            }
            
        }
        
        GTFSBundleDispatchGroup.notify(queue: downloadQueue, execute: {
            DispatchQueue.main.async(execute: {
                finished(!dirty, dlError)
            })
        })
        
    }
    
}
