//
//  FileManager+extension.swift
//  Luna
//
//  Created by Mart Civil on 2017/02/22.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UIKit

extension FileManager {

    public class func isExists( url:URL ) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public class func createDirectory( absolutePath:String, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: true, attributes: nil)
            if onSuccess != nil {
                onSuccess!( URL( fileURLWithPath: absolutePath ) )
            }
            return true
        } catch let error as NSError {
            if onFail != nil {
                onFail!( error.localizedDescription )
            }
        }
        return false
    }
    
    public class func createDirectory( relative:String, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        if let path = getDocumentsDirectoryPath(pathType: .DOCUMENT_TYPE , relative: relative) {
            return createDirectory( absolutePath: path.path, onSuccess:onSuccess, onFail:onFail )
        }
        return false
    }
    
    public class func generateDocumentFilePath( fileName:String, relativePath:String?=nil ) -> URL {
        return URL( fileURLWithPath: getDocumentsDirectoryPath( relative:relativePath )!.path ).appendingPathComponent( fileName )
    }
    
    public class func copyFile( filePath:URL, relativeTo:String?="", onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        let fileName = filePath.path.substring(from: filePath.path.lastIndexOf(target: "/")! + 1, to: filePath.path.length)
        let toURL = FileManager.getDocumentsDirectoryPath(relative:relativeTo)!.appendingPathComponent( fileName )

        if isExists(url: toURL) {
            if onFail != nil {
                onFail!( FileError.ALREADY_EXISTS.localizedDescription )
            }
            return false
        }
        return copyFile( from:filePath, to:toURL, onSuccess:onSuccess, onFail:onFail )
    }
    
    public class func copyFile( from:URL, to:URL, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        do {
            try FileManager.default.copyItem(atPath: from.path, toPath: to.path)
            if onSuccess != nil {
                onSuccess!( to )
            }
            return true
        }catch let error as NSError {
            if onFail != nil {
                onFail!( error.localizedDescription )
            }
        }
        return false
    }
    
    public class func renameFile( fileName:String, filePath:URL, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        let path = filePath.path.substring(from: 0, to: filePath.path.lastIndexOf(target: "/"))
        let toURL = URL( fileURLWithPath: path).appendingPathComponent( fileName )
        if isExists(url: toURL) {
            if onFail != nil {
                onFail!( "\(fileName) already exists" )
            }
            return false
        }
        return moveFile( from:filePath, to: toURL, onSuccess:onSuccess, onFail:onFail )
    }
    
    public class func moveFile( filePath:URL, newFileName:String?=nil, relative:String?=nil, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        var fileName:String!
        if newFileName != nil {
            fileName = newFileName
        } else {
            fileName = filePath.path.substring(from: filePath.path.lastIndexOf(target: "/")! + 1, to: filePath.path.length)
        }
        let toURL = generateDocumentFilePath( fileName:fileName, relativePath:relative )
        return moveFile( from:filePath, to:toURL, onSuccess:onSuccess, onFail:onFail )
    }
    
    public class func moveFile( document:String, relativeFrom:String?=nil, relativeTo:String?=nil, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        let fromURL = generateDocumentFilePath( fileName:document, relativePath:relativeFrom )
        let toURL = generateDocumentFilePath( fileName:document, relativePath:relativeTo )
        return moveFile( from:fromURL, to:toURL, onSuccess:onSuccess, onFail:onFail )
    }
    
    public class func moveFile( from:URL, to:URL, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        do {
            try FileManager.default.moveItem(at: from, to: to)
            if onSuccess != nil {
                onSuccess!( to )
            }
            return true
        }catch let error as NSError {
            if onFail != nil {
                onFail!( error.localizedDescription )
            }
        }
        return false
    }
    
    public class func getDocumentsDirectoryPath( pathType:FilePathType?=FilePathType.DOCUMENT_TYPE, relative:String?=nil ) -> URL? {
        if pathType == .DOCUMENT_TYPE {
            let paths = self.default.urls( for: .documentDirectory, in: .userDomainMask )
            if relative != nil {
                return URL( string:paths[0].absoluteString + relative!)!
            }
            return paths[0]
        } else if pathType == .BUNDLE_TYPE {
            if relative != nil {
                if let bundlePath = Bundle.main.path(forAuxiliaryExecutable: relative!) {
                    return URL( fileURLWithPath: bundlePath )
                }
            } else {
                return URL( fileURLWithPath:Bundle.main.bundlePath )
            }
        }
        return nil
    }
    
    
    public class func getDocumentsFileList( path:URL ) -> [URL]? {
        do {
            return try self.default.contentsOfDirectory(
                at: path,
                includingPropertiesForKeys: nil,
                options: []
            )
        } catch let error as NSError {
            print( error.localizedDescription )
        }
        return nil
    }
    
    public class func getDocumentsFileList( relative:String?=nil ) -> [URL]?{
        return getDocumentsFileList( path: getDocumentsDirectoryPath( relative: relative )! )
    }

    public class func createDocumentFolder( relative:String?=nil, onSuccess:(()->())?=nil, onFail:((String)->())?=nil ) {
        do {
            try self.default.createDirectory(atPath: getDocumentsDirectoryPath( relative:relative)!.path, withIntermediateDirectories: true, attributes: nil)
            if onSuccess != nil {
                onSuccess!()
            }
        } catch let error as NSError {
            if onFail != nil {
                onFail!(error.localizedFailureReason!)
            }
        }
    }
    
    public class func saveDocument( file: Any, filename: String, relative:String?=nil, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) {
        var data:Data = Data()
        
        switch( file ) {
        case is String:
            data = Utility.shared.StringToData( txt: file as! String )
        case is Data:
            data = file as! Data
        case is NSDictionary:
            data = Utility.shared.DictionaryToData(dict: file as! NSDictionary)
        case is UIImage:
            data = UIImagePNGRepresentation( file as! UIImage )!
        default:
            if onFail != nil {
                onFail!( FileError.INVALID_FORMAT.localizedDescription )
            }
        }
        
        let dataURL = getDocumentsDirectoryPath(relative:relative)!.appendingPathComponent( filename );
        do {
            try data.write(to: dataURL)
            if onSuccess != nil {
                onSuccess!( dataURL )
            }
        } catch let error {
            if onFail != nil {
                onFail!( error.localizedDescription )
            }
        }
    }
    
    public class func saveDocument( base64:String, filename:String, type:String, relative:String?=nil, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) {
        switch( type.uppercased() ) {
        case "IMAGE":
//            saveDocument( file:Utility.shared.base64ToImage( base64: base64 ), filename: filename, relative:relative,
//                          onSuccess:onSuccess, onFail:onFail )
            break
        default:  break;
        }
    }
    
    public class func deleteDocumentFile( fileName: String, relative:String?=nil, onSuccess:(()->())?=nil, onFail:((String)->())?=nil  ) -> Bool {
        let filePath = generateDocumentFilePath(fileName: fileName, relativePath: relative)
        return deleteFile( filePath:filePath, onSuccess:onSuccess, onFail:onFail )
    }
    
    public class func deleteFile( filePath: URL, onSuccess:(()->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        do {
            try FileManager.default.removeItem(at: filePath)
            if onSuccess != nil {
                onSuccess!()
            }
            return true
        }
        catch let error as NSError {
            if onFail != nil {
                onFail!(error.localizedFailureReason!)
            }
        }
        return false
    }
    
    public class func deleteDocumentFolder( relative:String?=nil, onSuccess:(()->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        do {
            try self.default.removeItem(at: getDocumentsDirectoryPath( relative:relative )!)
            if onSuccess != nil {
                onSuccess!()
            }
            return true
        } catch let error as NSError {
            if onFail != nil {
                onFail!(error.localizedFailureReason!)
            }
        }
        return false
    }
}
