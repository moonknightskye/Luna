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
    
    public override init( fileId:Int, document:String, filePath: URL ) {
        super.init( fileId:fileId, document:document, filePath:filePath )
    }
    
    public override init( fileId:Int, document:String, path:String?=nil, filePath:URL?=nil ) throws {
        try super.init( fileId:fileId, document: document, path: path, filePath: filePath)
    }

    public override init( fileId:Int, bundle:String, filePath: URL ) {
        super.init( fileId:fileId, bundle: bundle, filePath: filePath)
    }
    public override init( fileId:Int, bundle:String, path:String?=nil, filePath:URL?=nil) throws {
        try super.init( fileId:fileId, bundle: bundle, path: path, filePath: filePath)
    }

	override init ( fileId:Int, path:String?=nil, filePath: URL ) {
		super.init( fileId:fileId, path: path, filePath: filePath)
	}
    
    public override init( fileId:Int, url:String ) throws {
        try super.init( fileId:fileId, url:url )
        self.setFileExtension(fileext: .HTML)
    }
    
    public convenience init( file:NSDictionary ) throws {
        var isValid = true
        
        let fileName:String? = file.value(forKeyPath: "filename") as? String
        let path:String? = file.value(forKeyPath: "path") as? String
        let fileId:Int! = file.value(forKeyPath: "file_id") as? Int ?? File.generateID()
        
        if let pathType = file.value(forKeyPath: "path_type") as? String {
            if let filePathType = FilePathType( rawValue: pathType ) {
                switch filePathType {
                case FilePathType.BUNDLE_TYPE:
                    if fileName != nil {
                        try self.init( fileId:fileId, bundle: fileName!, path:path)
                        return
                    } else {
                        isValid = false
                    }
                    break
                case FilePathType.DOCUMENT_TYPE:
                    if fileName != nil {
                        try self.init( fileId:fileId, document: fileName!, path:path )
                        return
                    } else {
                        isValid = false
                    }
                    break
                case FilePathType.URL_TYPE:
                    if path != nil {
                        try self.init( fileId:fileId, url: path! )
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
        let fileId:Int! = htmlFile.value(forKeyPath: "file_id") as? Int ?? File.generateID()
        
        switch pathType {
        case FilePathType.BUNDLE_TYPE:
            let fileName:String = htmlFile.value(forKeyPath: "filename") as! String
            super.init( fileId:fileId, bundle:fileName, filePath:filePath )
            return
        case FilePathType.DOCUMENT_TYPE:
            let fileName:String = htmlFile.value(forKeyPath: "filename") as! String
            super.init( fileId:fileId, document:fileName, filePath:filePath )
            return
        case FilePathType.URL_TYPE:
            super.init()
            self.setID(fileId: fileId)
            self.setFilePath(filePath: filePath)
            self.setPathType(pathType: FilePathType.URL_TYPE)
            return
        default:
            break
        }
        super.init()
    }
    
}
