//
//  GTFSParser.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class GTFSParser : NSObject{
    
    var realm : Realm?
    
    #if DEBUG
    var startDate : NSDate?
    let debugClosure : (CSVParser, String, NSDate, NSDate)->Void = { (parser, filePath, start, end) in
        let pathComponents = filePath.componentsSeparatedByString("/")
        let fileName = pathComponents.last!
        print("finished parsing \(fileName) file")
        print("inserted \(parser.lineCount-1) objects in \(end.timeIntervalSinceDate(start)) seconds\n")
    }
    #endif
    
    func parseDocument(filePath: String, processValues: (structure: [String], line: [AnyObject]) -> Object?){
        
        let parser = CSVParser(path: filePath, structure: true,
                               
                               didStartDocument: { _ -> Void in
                                self.realm = try! Realm()
                                self.realm!.beginWrite()
                                #if DEBUG
                                self.startDate = NSDate()
                                #endif
                                },
                               
                               didReadLine: { parser, values in
                                let entry = processValues(structure: parser.header, line: values)
                                self.realm!.add(entry!)
                                
                                if parser.lineCount % 10000 == 0 {
                                    try! self.realm!.commitWrite()
                                    self.realm!.beginWrite()
                                }},
                               
                               didEndDocument: {parser -> Void in
                                try! self.realm!.commitWrite()
                                #if DEBUG
                                self.debugClosure(parser, filePath, self.startDate!, NSDate())
                                #endif
                                }
        )
        
        parser.startReader()
    }
    
    func parseLine<T:Object>(structure: Array<String>, line: Array<AnyObject>, model: T.Type) -> T?{
        
        if structure.count == line.count {
            let newEntry = model.init()
            for (index, key) in structure.enumerate(){
                newEntry.setValue(line[index], forKey: key)
            }
            return newEntry
        }
        
        print("problem creating realm object")
        //to-do: tratar erro
        return nil
    }
    
    
}
