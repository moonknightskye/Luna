//
//  HTMLFile.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/16.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

class HtmlFile: File {
    
    override init(){
        super.init()
    }
    
    public override init( document:String, filePath: URL ) {
        super.init( document:document, filePath:filePath )
    }
    
    public override init( document:String, path:String?=nil, filePath:URL?=nil ) throws {
        try super.init(document: document, path: path, filePath: filePath)
    }

    public override init( bundle:String, filePath: URL ) {
        super.init(bundle: bundle, filePath: filePath)
    }
    public override init( bundle:String, path:String?=nil, filePath:URL?=nil) throws {
        try super.init(bundle: bundle, path: path, filePath: filePath)
    }
    
    public override init( url:String ) throws {
        try super.init( url:url )
        self.setFileExtension(fileext: .HTML)
    }
    
    public convenience init( file:NSDictionary ) throws {
        var isValid = true
        
        let fileName:String? = file.value(forKeyPath: "filename") as? String
        let path:String? = file.value(forKeyPath: "path") as? String
        
        if let pathType = file.value(forKeyPath: "path_type") as? String {
            if let filePathType = FilePathType( rawValue: pathType ) {
                switch filePathType {
                case FilePathType.BUNDLE_TYPE:
                    if fileName != nil {
                        try self.init( bundle: fileName!, path:path)
                        return
                    } else {
                        isValid = false
                    }
                    break
                case FilePathType.DOCUMENT_TYPE:
                    if fileName != nil {
                        try self.init( document: fileName!, path:path )
                        return
                    } else {
                        isValid = false
                    }
                    break
                case FilePathType.URL_TYPE:
                    if path != nil {
                        try self.init( url: path! )
                        return
                    }else {
                        isValid = false
                    }
                default:
                    isValid = false
                    break
                }
                
            } else {
                isValid = false
            }
        } else {
            isValid = false
        }
        
        if !isValid {
            throw FileError.INVALID_PARAMETERS
        }
        self.init()
    }
    
    public init( htmlFile: NSDictionary ) {
        let filePath:URL = URL( string: htmlFile.value(forKeyPath: "file_path") as! String )!
        let pathType = FilePathType( rawValue: htmlFile.value(forKeyPath: "path_type") as! String )!
        switch pathType {
        case FilePathType.BUNDLE_TYPE:
            let fileName:String = htmlFile.value(forKeyPath: "filename") as! String
            super.init( bundle:fileName, filePath:filePath )
            return
        case FilePathType.DOCUMENT_TYPE:
            let fileName:String = htmlFile.value(forKeyPath: "filename") as! String
            super.init( document:fileName, filePath:filePath  )
            return
        case FilePathType.URL_TYPE:
            super.init( filePath:filePath )
            return
        default:
            break
        }
        super.init()
    }
    
}
