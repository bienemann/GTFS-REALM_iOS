//
//  GTFSManager.swift
//  sptransAPI
//
//  Created by Allan Denis Martins on 8/3/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import Alamofire

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
    
    func hasAllFiles() -> Bool{
        for (_, value) in self.fileNames {
            if value == nil {return false}
        }
        return true
    }
    
    func downloadGTFS(finished: Bool -> Void){
        
        let downloadQueue = dispatch_queue_create("com.mydlqueue", DISPATCH_QUEUE_CONCURRENT)
        let GTFSBundleDispatchGroup = dispatch_group_create()
        
        for (key, _) in self.fileNames {
            
            dispatch_group_enter(GTFSBundleDispatchGroup)
            var filePath : NSURL?
            Alamofire.download(.GET, "\(self.baseURL)/\(key).txt") { (tempURL, response) in
                let dirURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let fileName = response.suggestedFilename!
                filePath = dirURL.URLByAppendingPathComponent(fileName)
                return filePath!
                }.response(completionHandler: { (request, resonse, data, error) in
                    if filePath != nil {
                        self.fileNames.updateValue(filePath!.URLString, forKey: key)
                        dispatch_group_leave(GTFSBundleDispatchGroup)
                    }
                })
                
            
        }
        
        dispatch_group_notify(GTFSBundleDispatchGroup, downloadQueue, {
            dispatch_async(dispatch_get_main_queue(), {
                finished(true)
            })
        })
        
    }
    
}