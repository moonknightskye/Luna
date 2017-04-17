//
//  ZipFile.swift
//  Luna
//
//  Created by 志美瑠 真斗 on 2017/04/08.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import Zip

class ZipFile: File {

    static var LIST:[ZipFile] = [ZipFile]()
    //static var counter1 = 0;
    
    //private var zipfile_id = ZipFile.counter1
	private var unzipPath:String = SystemFilePath.DOCUMENT.rawValue
    private var password:String?
    private var isOverwrite:Bool = false

	override init(){
		super.init()
	}

	override init( fileId:Int, document:String, filePath: URL) {
        super.init( fileId:fileId, document:document, filePath:filePath )
        add()
	}

	override init( fileId:Int, document:String, path:String?=nil, filePath:URL?=nil ) throws {
		try super.init( fileId:fileId, document: document, path: path, filePath: filePath)
        add()
	}

	override init( fileId:Int, bundle:String, filePath: URL ) {
		super.init( fileId:fileId, bundle: bundle, filePath: filePath)
        add()
	}
    override init( fileId:Int, bundle:String, path:String?=nil, filePath:URL?=nil) throws {
		try super.init( fileId:fileId, bundle: bundle, path: path, filePath: filePath)
        add()
	}

	override init ( fileId:Int, path:String?=nil, filePath: URL ) {
		super.init( fileId:fileId, path: path, filePath: filePath)
		add()
	}
    
    override init( fileId:Int, url:String ) throws {
        try super.init( fileId:fileId, url:url )
        add()
    }

    convenience init( file:NSDictionary ) throws {
        var isValid = true
        
        let fileName:String? = file.value(forKeyPath: "filename") as? String
        let path:String? = file.value(forKeyPath: "path") as? String
        let filePath:String? = file.value(forKeyPath: "file_path") as? String
        let fileId:Int! = file.value(forKeyPath: "file_id") as? Int ?? File.generateID()
        
        var filePathURL:URL? = nil
        if filePath != nil {
            filePathURL = URL(string: filePath!)!
        }
        
        if let pathType = file.value(forKeyPath: "path_type") as? String {
            if let filePathType = FilePathType( rawValue: pathType ) {
                switch filePathType {
                case FilePathType.BUNDLE_TYPE:
                    if fileName != nil {
                        try self.init( fileId:fileId, bundle: fileName!, path:path, filePath:filePathURL)
                        return
                    } else {
                        isValid = false
                    }
                    break
                case FilePathType.DOCUMENT_TYPE:
                    if fileName != nil {
                        try self.init( fileId:fileId, document: fileName!, path:path, filePath:filePathURL )
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
    
    private func add() {
        //ZipFile.counter1 += 1;
        ZipFile.LIST.append( self )
    }
    
    public class func getZipFile( fileId:Int ) -> ZipFile? {
        for (_, zipfile) in ZipFile.LIST.enumerated() {
            if  zipfile.getID() == fileId{
                return zipfile
            }
        }
        return nil
    }
    
    func remove() {
        ZipFile.remove( file: self )
        print("Removed zipped file \(self.getID())")
    }
    
    public class func remove( file: ZipFile ) {
        for ( index, zipfile) in ZipFile.LIST.enumerated() {
            if zipfile === file{
                ZipFile.LIST.remove(at: index)
            }
        }
    }
    
    func unzip( to:String?=nil, isOverwrite:Bool?=false, password:String?="", onSuccess:@escaping(()->()), onFail:((String)->()) ) {

        if self.getPathType() == FilePathType.URL_TYPE {
            onFail( FileError.INVALID_FORMAT.localizedDescription )
            return
        }
        
        self.password = password ?? ""
        self.isOverwrite = isOverwrite ?? false
        
        do {
            var destination:URL?
            if to != nil {
                self.unzipPath = to!
                destination = FileManager.getDocumentsDirectoryPath()!.appendingPathComponent(to!)
            } else {
                if let filePath = self.getFilePath()?.absoluteString {
                    let path = filePath.substring(from: 0, to: filePath.lastIndexOf(target: "/")! + 1)
                    destination = URL(string: path)
                }
            }
            
            if let filePath = self.getFilePath(), let url = destination {
                var isStart = false
                try Zip.unzipFile(filePath, destination: url, overwrite: self.isOverwrite, password: self.password, progress: { (progress) -> () in
                    
                    if !isStart {
                        isStart = true
                        self.onUnzip()
                        onSuccess()
                    }
                    
                    self.onUnzipping( progress: progress * 100 )
                    
                    if progress >= 1.0 {
                        self.onUnzipped(unzippedFilePath: url)
                        self.remove()
                    }
                })
                
                return
            }
        } catch let error as NSError {
            onFail( error.localizedDescription )
            remove()
            return
        }
        onFail( FileError.UNKNOWN_ERROR.localizedDescription )
        remove()
    }
    
//    public override func toDictionary() -> NSDictionary {
//        let dict = NSMutableDictionary()
//        if let filename = self.getFileName() {
//            dict.setValue(filename, forKey: "filename")
//        }
//        if let path = self.getPath() {
//            dict.setValue(path, forKey: "path")
//        }
//        if let pathType = self.getPathType() {
//            dict.setValue(pathType.rawValue, forKey: "path_type")
//        }
//        if let filePath = self.getFilePath() {
//            dict.setValue(filePath.absoluteString, forKey: "file_path")
//        }
//        dict.setValue(self.getFileExtension().rawValue, forKey: "file_extension")
//        dict.setValue(self.zipfile_id, forKey: "zipfile_id")
//        return dict
//    }
//    
//    override func getID() -> Int {
//        return self.zipfile_id
//    }

	func setUnzipPath( unzipPath:String ) {
		self.unzipPath = unzipPath
	}

	func getUnzipPath() -> String {
		return self.unzipPath
	}
    
    func onUnzip() {
        CommandProcessor.processOnUnzip(file: self)
    }
    
    func onUnzipped( unzippedFilePath:URL ) {
        CommandProcessor.processOnUnzipped(file: self, unzippedFilePath:unzippedFilePath)
    }
    
    func onUnzipping( progress: Double ) {
        CommandProcessor.processOnUnzipping(file: self, progress: progress)
    }



}
