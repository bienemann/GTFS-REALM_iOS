//
//  CSVParser.swift
//  CSV
//
//  Created by Allan Hoeltje on 8/3/16.
//  Copyright © 2016 Allan Hoeltje.
//
//	The algorithm employed here in the parse method was gleaned from libcsv by Robert Gamble.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//	the Software, and to permit persons to whom the Software is furnished to do so,
//	subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import RealmSwift

/// A class for handling comma-separated-values text files.
/// The value delimiter defaults to "," but can be any other character you like.


open class CSVParser: NSObject
{
    let csvFile: TextFile
    fileprivate var delim: UInt32
    fileprivate var delimiter: String
    fileprivate var quote: UInt32
    open var indexed: Bool = false
    open var header : [String] = []
    
    open var converterClosure : (([String], [AnyObject]) -> GTFSBaseModel?)?

    open var doBeforeLine: ((CSVParser, [Any]) -> Void)?
    open var doWhileProcessingLine: ((CSVParser, [Any]) -> Void)?
    open var doAfterLine: ((CSVParser, [Any]) -> Void)?
    
    /// The current line number being processed in the CSV file
    open var lineCount = 0
    open var csvStreamReader : StreamReader? = nil
    
    enum ParserState
    {
        case row_NOT_BEGUN				//	There have not been any fields encountered for this row
        case field_NOT_BEGUN			//	There have been fields but we are currently not in one
        case field_BEGUN				//	We are in a field
        case field_MIGHT_HAVE_ENDED		//	We encountered a double quote inside a quoted field
    }
    
    fileprivate var pstate		= ParserState.field_NOT_BEGUN
    fileprivate var quoted		= false
    fileprivate var spaces		= 0
    fileprivate var entryPos	= 0
    
    fileprivate var startClosure : ((CSVParser)->Void)?
    fileprivate var endClosure : ((CSVParser)->Void)?
    fileprivate var readLineClosure : ((CSVParser, Array<Any>) -> Void)?
    
    fileprivate let csvTab: UInt32		= 0x09
    fileprivate let csvSpace: UInt32	= 0x20
    fileprivate let csvCR: UInt32		= 0x0d
    fileprivate let csvLF: UInt32		= 0x0a
    fileprivate let csvComma: UInt32	= 0x2c
    fileprivate let csvQuote: UInt32	= 0x22
    
    
    /// Initialize the CSV object with a file path.
    /// - Parameters:
    ///   - path: an input path for a CSV reader or an output path for a writer.
    ///   - delegate: the parser delegate object
    public init(path: String, structure: Bool = false,
                didStartDocument: ((CSVParser)->Void)? = nil,
                didEndDocument: ((CSVParser)->Void)? = nil,
                didReadLine: ((CSVParser, Array<Any>) -> Void)? = nil){
        
        self.csvFile = TextFile(path: path)
        self.delimiter = ""
        self.delim = 0
        self.quote = 0
        
        self.startClosure = didStartDocument
        self.endClosure = didEndDocument
        self.readLineClosure = didReadLine
        
        self.indexed = structure
        
    }
    
    /// A CSV reader.
    /// - Parameters:
    ///   - delimiter: optional delimeter character, defaults to ","
    ///   - quote: optional quote character, defaults to "\"".  A field in a CSV file that contains the delimiter character should be quoted.
    open func startReader(_ delimiter: String = ",", quote: String = "\"")
    {
        self.delimiter = delimiter
        self.delim	= (delimiter.unicodeScalars.first?.value)!
        self.quote	= (quote.unicodeScalars.first?.value)!
        
        lineCount = 0

        csvStreamReader = self.csvFile.reader()
        if csvStreamReader != nil{
            
            if startClosure != nil { startClosure!(self) }
            
            var line = csvStreamReader!.nextLine()
            while line != nil{
                autoreleasepool(invoking: { 
                    
                    let parsedLine = parse(line!)
                    lineCount += 1
                    
                    if doBeforeLine != nil { doBeforeLine!(self, parsedLine) }
                    
                    if self.indexed {
                        if lineCount == 1 {
                            self.header = parsedLine as! [String]
                            line = csvStreamReader!.nextLine()
                            return
                        }
                        if readLineClosure != nil { readLineClosure!(self, parsedLine) }
                        if doWhileProcessingLine != nil { doWhileProcessingLine!(self, parsedLine) }
                    }else{
                        if readLineClosure != nil { readLineClosure!(self, parsedLine) }
                    }
                    
                    line = csvStreamReader!.nextLine()
                    
                    if doAfterLine != nil { doAfterLine!(self, parsedLine) }
                })
            }
            
            csvStreamReader!.close()
        }

        if endClosure != nil { endClosure!(self) }
    }
    
    /// A CSV writer.
    /// - Parameters:
    ///   - delimiter: optional delimeter character, defaults to ","
    ///   - quote: optional quote character, defaults to "\"".  A field in a CSV file that contains the delimiter character should be quoted.
    open func writer(_ delimiter: String = ",", quote: String = "\"")
    {
        self.delimiter = delimiter
        self.delim	= (delimiter.unicodeScalars.first?.value)!
        self.quote	= (quote.unicodeScalars.first?.value)!
        
        //	TODO: CSV writer
    }
    
    //	used to time the TextFile reader without csv parsing getting in the way
    fileprivate func xparse(_ line: String) -> [String]
    {
        let components = [String]()
        return components
    }
    
    fileprivate func parse(_ line: String) -> [Any]
    {
        //		print( "\n\(line)")
        
        var components = [Any]()
        var field = ""
        
        entryPos	= 0
        quoted		= false
        spaces		= 0
        pstate		= .row_NOT_BEGUN
        
        for ch in line.unicodeScalars
        {
            let c = ch.value
            switch pstate
            {
            case .row_NOT_BEGUN:
                fallthrough
            case .field_NOT_BEGUN:
                if ((c == csvSpace) || (c == csvTab)) && (c != delim)
                {
                    //	space or tab
                    //	continue
                }
                else
                    if c == delim
                    {
                        components.append(field as AnyObject)	//	SUBMIT_FIELD
                        field = ""
                        
                        entryPos	= 0
                        quoted		= false
                        spaces		= 0
                        pstate		= .field_NOT_BEGUN
                    }
                    else
                        if c == quote
                        {
                            quoted = true
                            pstate = .field_BEGUN
                        }
                        else
                        {
                            field.append(String(ch))			//	SUBMIT_CHAR
                            entryPos += 1
                            quoted = false
                            pstate = .field_BEGUN
                }
                
            case .field_BEGUN:
                if c == quote
                {
                    if quoted
                    {
                        field.append(String(ch))		//	SUBMIT_CHAR
                        entryPos += 1
                        pstate = .field_MIGHT_HAVE_ENDED
                    }
                    else
                    {
                        //	double quote inside non-quoted field
                        //						if (p->options & CSV_STRICT)
                        //						{
                        //							p->status = CSV_EPARSE;
                        //							p->quoted = quoted, p->pstate = pstate, p->spaces = spaces, p->entry_pos = entry_pos;
                        //							return pos-1;
                        //						}
                        
                        field.append(String(ch))		//	SUBMIT_CHAR
                        entryPos += 1
                        spaces = 0
                    }
                }
                else
                    if c == delim
                    {
                        //	Delimiter
                        if quoted
                        {
                            field.append(String(ch))		//	SUBMIT_CHAR
                            entryPos += 1
                        }
                        else
                        {
                            components.append(field.numberValue())	//	SUBMIT_FIELD --can be anything
                            field = ""
                            
                            entryPos	= 0
                            quoted		= false
                            spaces		= 0
                            pstate		= .field_NOT_BEGUN
                        }
                    }
                    else
                        if !quoted && ((c == csvSpace) || (c == csvTab))
                        {
                            //	Tab or space for non-quoted field
                            
                            field.append(String(ch))			//	SUBMIT_CHAR
                            entryPos += 1
                            spaces += 1
                        }
                        else
                        {
                            field.append(String(ch))			//	SUBMIT_CHAR
                            entryPos += 1
                            spaces = 0
                }
                
            case .field_MIGHT_HAVE_ENDED:
                //	This only happens when a quote character is encountered in a quoted field
                if c == delim
                {
                    let range = field.characters.index(field.endIndex, offsetBy: -(spaces + 1)) ..< field.endIndex
                    field.removeSubrange(range)
                    
                    entryPos -= (spaces + 1)	//	get rid of spaces and original quote
                    components.append(field as AnyObject)	//	SUBMIT_FIELD -- might be quoted text
                    field = ""
                    
                    entryPos	= 0
                    quoted		= false
                    spaces		= 0
                    pstate		= .field_NOT_BEGUN
                }
                else
                    if (c == csvSpace) || (c == csvTab)
                    {
                        field.append(String(ch))			//	SUBMIT_CHAR
                        entryPos += 1
                        spaces += 1
                    }
                    else
                        if c == quote
                        {
                            if spaces > 0
                            {
                                //	STRICT ERROR - unescaped double quote
                                //						if (p->options & CSV_STRICT)
                                //						{
                                //							p->status = CSV_EPARSE;
                                //							p->quoted = quoted;
                                //							p->pstate = pstate;
                                //							p->spaces = spaces;
                                //							p->entry_pos = entry_pos;
                                //							return pos-1;
                                //						}
                                
                                field.append(String(ch))		//	SUBMIT_CHAR
                                entryPos += 1
                                spaces = 0
                            }
                            else
                            {
                                //	Two quotes in a row
                                pstate = .field_BEGUN
                            }
                        }
                        else
                        {
                            //	Anything else
                            field.append(String(ch))			//	SUBMIT_CHAR
                            entryPos += 1
                            spaces = 0
                            pstate = .field_BEGUN
                }
            }
        }
        
        if pstate == .field_BEGUN
        {
            //	We still have an unfinished field
            components.append(field.numberValue()) // --might be anything, always last component
        }
        else
            if pstate == .field_MIGHT_HAVE_ENDED
            {
                if !field.isEmpty
                {
                    let range = field.characters.index(field.endIndex, offsetBy: -(spaces + 1)) ..< field.endIndex
                    field.removeSubrange(range)
                    components.append(field as AnyObject) // --might be quoted txt, always last omponent
                }
        }
        
        return components
    }
}

extension String {
    
    func numberValue() -> Any {
        if let a = Int(self) {
            return a
        }
        if let b = Double(self) {
            return b
        }else{
            return self
        }
    }

}
