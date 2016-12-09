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
    var progressClosure : (() -> Double)?
    
    #if DEBUG
    var startDate : NSDate?
    let debugClosure : (CSVParser, String, NSDate, NSDate)->Void = { (parser, filePath, start, end) in
        let pathComponents = filePath.componentsSeparatedByString("/")
        let fileName = pathComponents.last!
//        print("finished parsing \(fileName) file")
//        print("inserted \(parser.lineCount-1) objects in \(end.timeIntervalSinceDate(start)) seconds\n")
    }
    #endif
    
    func parseDocument(_ filePath: String,
                       processValues: @escaping (_ structure: Array<String>, _ line: Array<Any>) -> GTFSBaseModel?,
                       progress: ((Double, Double)->Void)?){
        
        var fileSize : UInt64 = 0
        let parser = CSVParser(path: filePath, structure: true,
                               
                               didStartDocument: { parser -> Void in
                                fileSize = parser.csvStreamReader!.fileSize
                                self.realm = try! Realm()
                                self.realm!.beginWrite()
                                #if DEBUG
                                self.startDate = NSDate()
                                #endif
                                },
                               
                               didEndDocument: {parser -> Void in
                                try! self.realm!.commitWrite()
                                #if DEBUG
                                self.debugClosure(parser, filePath, self.startDate!, NSDate())
                                #endif
                                if progress != nil{
                                    progress!(Double(fileSize/10), Double(fileSize/10))
                                }},
                               
                               didReadLine: { parser, values in
                                let entry = processValues(parser.header, values)
                                self.realm!.add(entry!)
                                if parser.lineCount % 10000 == 0 {
                                
                                    if progress != nil{
                                        progress!(Double((parser.csvStreamReader?.fileHandle?.offsetInFile)!/10),
                                            Double(fileSize/10))
                                    }
                                    
                                    try! self.realm!.commitWrite()
                                    self.realm!.beginWrite()
                                }}
        )
        
        parser.startReader()
    }
    
    func parseLine<T:GTFSBaseModel>(_ structure: Array<String>, line: Array<Any>, model: T.Type) -> T?{
        
        if structure.count == line.count {
            return model.init(values: line, keys: structure, typecast: model.typecast())
        }
        
        print("problem creating realm object")
        //to-do: tratar erro
        return nil
    }
    
    
}
