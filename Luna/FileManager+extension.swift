//
//  FileManager+extension.swift
//  Luna
//
//  Created by Mart Civil on 2017/02/22.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UIKit
import Zip

extension FileManager {

    public class func isExists( url:URL ) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }

	public class func share( filePaths:[URL], onSuccess:@escaping((Bool)->()) ) {
		let activityVC = UIActivityViewController(activityItems: filePaths, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            print("activity: \(String(describing: activity)), success: \(success), items: \(String(describing: items)), error: \(String(describing: error?.localizedDescription))")
        }
		Shared.shared.ViewController.present(activityVC, animated: true, completion: {
			onSuccess( true )
		})
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
    
    public class func generateDocumentFilePath( fileName:String, relativePath:String?=nil ) -> URL? {
		return getDocumentsDirectoryPath( relative:relativePath )?.appendingPathComponent(fileName)
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
            try FileManager.default.copyItem(at: from, to: to)
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
		if let toURL = generateDocumentFilePath( fileName:fileName, relativePath:relative ) {
			return moveFile( from:filePath, to:toURL, onSuccess:onSuccess, onFail:onFail )
		}
		return false
	}
    
    public class func moveFile( document:String, relativeFrom:String?=nil, relativeTo:String?=nil, onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        if let fromURL = generateDocumentFilePath( fileName:document, relativePath:relativeFrom ),
			let toURL = generateDocumentFilePath( fileName:document, relativePath:relativeTo ) {
			return moveFile( from:fromURL, to:toURL, onSuccess:onSuccess, onFail:onFail )
		}
		return false
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
		} else if pathType == .ICLOUD_TYPE {
			if let path = self.default.url(forUbiquityContainerIdentifier: nil) {
				if relative != nil {
					return path.appendingPathComponent(relative!)
				}
				return path
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
		if let filePath = generateDocumentFilePath(fileName: fileName, relativePath: relative) {
			return deleteFile( filePath:filePath, onSuccess:onSuccess, onFail:onFail )
		}
		if onFail != nil {
			onFail!(FileError.UNKNOWN_ERROR.localizedDescription)
		}
		return false
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
    
    public class func zip( filePaths:[URL], resultFilePath:URL, password:String?=nil, onProgress:@escaping((Double)->()), onSuccess:@escaping((Bool)->()), onFail:@escaping((String)->()), onFinished:@escaping ((URL)->())) {
    
        do {
            var isStart = false
            var isFinished = false
            try Zip.zipFiles(paths: filePaths, zipFilePath: resultFilePath, password: password, compression: .BestCompression, progress: { (progress) in
                
                if isFinished {
                    return
                }
                if !isStart {
                    onSuccess( true )
                    isStart = true
                }
                
                onProgress( progress * 100 )
                
                if progress >= 1.0 {
                    onFinished( resultFilePath )
                    isFinished = true
                }
            })
        } catch let error as NSError {
            onFail( error.localizedDescription )
        }
    }
    
    public class func unzip( filePath:URL, destination:URL, overwrite:Bool, password:String?=nil, onProgress:@escaping ((Double)->()), onSuccess:@escaping ((Bool)->()), onFail:((String)->()), onFinished:@escaping ((URL)->()) ) {
    
        do {
            var isStart = false
            try Zip.unzipFile(filePath, destination: destination, overwrite: overwrite, password: password, progress: { (progress) -> () in
                
                if !isStart {
                    isStart = true
                    onSuccess( true )
                }
                
                onProgress( progress * 100 )
                
                if progress >= 1.0 {
                    onFinished( destination )
                }
            })
        } catch let error as NSError {
            onFail( error.localizedDescription )
        }
    }

	public class func initiCloudDirectory() {
		if let iCloudDocumentURL = getDocumentsDirectoryPath(pathType: .ICLOUD_TYPE) {
			Shared.shared.iCloudAvailable = true

			if !isExists(url: iCloudDocumentURL) {
				let _ = createDirectory(absolutePath: iCloudDocumentURL.absoluteString)
			}
            
            //Download & sync files
            if let cloudFileCollection = getDocumentsFileList( path: iCloudDocumentURL ) {
                for (_, cloudFile) in cloudFileCollection.enumerated() {
                    if self.default.isUbiquitousItem(at: cloudFile) {
                        do {
                            try self.default.startDownloadingUbiquitousItem(at: cloudFile)
                        } catch{}
                    }
                }
            }
            
            //THIS METHOD WILL EVICT ITEMS
            //try FileManager.default.evictUbiquitousItem(at: image)
            
            //https://developer.apple.com/reference/foundation/filemanager/1413989-setubiquitous
            //Sets whether the item at the specified URL should be stored in the cloud.
            //func setUbiquitous(_ flag: Bool, itemAt url: URL, destinationURL: URL) throws
            //Specify true to move the item to iCloud or false to remove it from iCloud (if it is there currently).
        }
	}
}
