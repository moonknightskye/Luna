//
//  VideoFile.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/21.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import AVFoundation

class VideoFile: File {

    private var player:AVPlayer?
    
    override init(){
        super.init()
    }
    
    public override init( document:String, filePath: URL) {
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
    
//    public override init( filePath: URL ) {
//        super.init( filePath:filePath )
//    }
    
    public override init( url:String ) throws {
        try super.init( url:url )
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
    
    public init( videoFile: NSDictionary ) {
        let filePath:URL = URL( string: videoFile.value(forKeyPath: "file_path") as! String )!
        let pathType = FilePathType( rawValue: videoFile.value(forKeyPath: "path_type") as! String )!
        
        switch pathType {
        case FilePathType.BUNDLE_TYPE:
            let fileName:String = videoFile.value(forKeyPath: "filename") as! String
            super.init( bundle:fileName, filePath:filePath)
            return
        case FilePathType.DOCUMENT_TYPE:
            let fileName:String = videoFile.value(forKeyPath: "filename") as! String
            super.init( document:fileName, filePath:filePath )
            return
        case FilePathType.URL_TYPE:
            super.init()
            self.setFilePath(filePath: filePath)
            self.setPathType(pathType: FilePathType.URL_TYPE)
            return
        default:
            break
        }
        super.init()
    }
    
    public func getBase64Value( onSplit:@escaping ((Data)->()), onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        switch self.getPathType()! {
        case .ASSET_TYPE:
            onFail( "PLEASE SUPPORT THIS" )
            break
        case .BUNDLE_TYPE, .DOCUMENT_TYPE:
            if let file = self.getFile() {
                Utility.shared.splitDataToChunks(file: file, onSplit: { (chunk) in
                    onSplit(chunk)
                }, onSuccess: { (result) in
                    onSuccess(result)
                })
            }
            break
        default:
            onFail( FileError.UNKNOWN_ERROR.localizedDescription )
            break
        }
    }
    
    public func getAVPlayer() -> AVPlayer? {
        if player == nil {
            if let filePath = self.getFilePath() {
                player = AVPlayer(url: filePath)
                player!.actionAtItemEnd = .pause
            }
        }
        return player
    }
    
}
