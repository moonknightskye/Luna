//
//  VideoFile.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/21.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

class VideoFile: File {

    private var player:AVPlayer?
    private var asset:PHAsset?
    
    override init(){
        super.init()
    }
    
    override init( fileId:Int, document:String, filePath: URL) {
        super.init( fileId:fileId, document:document, filePath:filePath )
    }
    
    override init( fileId:Int, document:String, path:String?=nil, filePath:URL?=nil ) throws {
        try super.init( fileId:fileId, document: document, path: path, filePath: filePath)
    }
    
    
    override init( fileId:Int, bundle:String, filePath: URL ) {
        super.init( fileId:fileId, bundle: bundle, filePath: filePath)
    }
    override init( fileId:Int, bundle:String, path:String?=nil, filePath:URL?=nil) throws {
        try super.init( fileId:fileId, bundle: bundle, path: path, filePath: filePath)
    }
    
	override init ( fileId:Int, path:String?=nil, filePath: URL ) {
		super.init( fileId:fileId, path: path, filePath: filePath)
	}

    override init( fileId:Int, url:String ) throws {
        try super.init( fileId:fileId, url:url )
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
    
    public init( videoFile: NSDictionary ) {
        let filePath:URL = URL( string: videoFile.value(forKeyPath: "file_path") as! String )!
        let pathType = FilePathType( rawValue: videoFile.value(forKeyPath: "path_type") as! String )!
        let fileId:Int! = videoFile.value(forKeyPath: "file_id") as? Int ?? File.generateID()
        
        switch pathType {
        case FilePathType.BUNDLE_TYPE:
            let fileName:String = videoFile.value(forKeyPath: "filename") as! String
            super.init( fileId:fileId, bundle:fileName, filePath:filePath)
            return
        case FilePathType.DOCUMENT_TYPE:
            let fileName:String = videoFile.value(forKeyPath: "filename") as! String
            super.init( fileId:fileId, document:fileName, filePath:filePath )
            return
        case FilePathType.URL_TYPE:
            super.init()
            self.setFilePath(filePath: filePath)
            self.setPathType(pathType: FilePathType.URL_TYPE)
            return
        case FilePathType.ASSET_TYPE:
            let fileName:String = videoFile.value(forKeyPath: "filename") as! String
            super.init( fileId:fileId, asset:fileName, filePath:filePath )
            if let asset = Photos.getVideoAsset(fileURL: filePath) {
                self.asset = asset
            }
            return
        default:
            break
        }
        super.init()
    }
    
    public init( fileId:Int, assetURL:URL ) throws {
        super.init()
        if let asset = Photos.getVideoAsset(fileURL: assetURL) {
            self.asset = asset
            
            self.setID(fileId: fileId)
            self.setFileName(fileName: asset.value(forKey: "filename") as! String)
            self.setPathType(pathType: FilePathType.ASSET_TYPE)
            self.setFilePath(filePath: assetURL )
        } else {
            throw FileError.INEXISTENT
        }
    }
    
    public func getBase64Value( onSplit:@escaping ((Data)->()), onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        switch self.getPathType()! {
        case .ASSET_TYPE:
            Photos.getBinaryVideo(asset: self.asset!, onSuccess: { (file) in
                Utility.shared.splitDataToChunks(file: file, onSplit: { (chunk) in
                    onSplit(chunk)
                }, onSuccess: { (result) in
                    onSuccess(result)
                })
            }, onFail: { (message) in
                onFail( message )
            })
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
