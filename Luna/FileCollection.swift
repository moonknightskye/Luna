//
//  FileCollection.swift
//  Luna
//
//  Created by Mart Civil on 2017/04/11.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import Zip

class FileCollection {
    
    private var Id:Int?
    private var FILES:[File] = [File]()
    private var DIRECTORIES:[URL] = [URL]()
    private var path:String = SystemFilePath.DOCUMENT.rawValue
    private var pathType:FilePathType = FilePathType.DOCUMENT_TYPE
    private var filePath:URL?
    static var counter = 0;
    
    public init(){}
    
    convenience init( fileCol: NSDictionary ) throws {
        let path:String? = fileCol.value(forKeyPath: "path") as? String
        var filePathURL:URL?
        let filePath:String? = fileCol.value(forKeyPath: "file_path") as? String
        if filePath != nil {
            filePathURL = URL(string: filePath!)
        }
        
        if let pathType = fileCol.value(forKeyPath: "path_type") as? String {
            if let filePathType = FilePathType( rawValue: pathType ) {
                switch filePathType {
                case .BUNDLE_TYPE, .DOCUMENT_TYPE, .ICLOUD_TYPE:
                    try self.init(relative: path!, pathType: filePathType, filePath:filePathURL )
                    return
                default:
                    break
                }
            }
        }
        throw FileError.INVALID_PARAMETERS
        self.init()
    }
    
    init( relative:String, pathType:FilePathType?=nil, filePath:URL?=nil ) throws {
		self.setPath(path: relative)

        if pathType != nil {
            self.setPathType(pathType: pathType!)
        }
        if filePath != nil {
            self.setFilePath(filePath: filePath!)
        }

		if !FileManager.isExists(url: self.getFilePath()!) {
			throw FileError.INEXISTENT
		}
        
        if let fileCollection = FileManager.getDocumentsFileList( path: self.getFilePath()! ) {
            for (_, file) in fileCollection.enumerated() {
                if file.absoluteString.endsWith(string: "/") {
                    self.DIRECTORIES.append(file)
                } else {
					var fileObj:File?
					let fileExt = File.getFileExtension(filename: file.absoluteString )
					switch( File.getFileType(fileExt:fileExt) ) {
                    case .ZIP_FILE:
						fileObj = ZipFile( fileId:File.generateID(), path: self.path, filePath: file )
						break
					case .IMAGE_FILE:
						fileObj = ImageFile( fileId:File.generateID(), path: self.path, filePath: file )
						break
					case .VIDEO_FILE:
						fileObj = VideoFile( fileId:File.generateID(), path: self.path, filePath: file )
						break
					case .HTML_FILE:
						fileObj = HtmlFile( fileId:File.generateID(), path: self.path, filePath: file )
						break
                    default:
						fileObj = File( fileId:File.generateID(), path: self.path, filePath: file )
                        break
                    }
                    self.FILES.append( fileObj! )
                }
            }
        }
    }
    
    func setID(Id: Int) {
        if self.Id == nil {
            self.Id = Id
        } else {
            print("[ERROR] File ID already set")
        }
    }
    func getID() -> Int {
        if self.Id == nil {
            self.Id = FileCollection.generateID()
        }
        return self.Id!
    }
    public class func generateID() -> Int {
        FileCollection.counter += 1
        return FileCollection.counter
    }
    
    public func getPathType() -> FilePathType? {
        return self.pathType
    }
    public func setPathType( pathType: FilePathType ) {
        self.pathType = pathType
    }
    public func setPathType( pathType: String ) {
        if let ptype = FilePathType(rawValue: pathType) {
            self.pathType = ptype
        }
    }
    
    func setFilePath( filePath: URL) {
        self.filePath = filePath
    }
    func getFilePath() -> URL? {
        if self.filePath == nil {
            self.filePath = self.generateFilePath()
        }
        return self.filePath
    }
    
    public func setPath( path:String ) {
        self.path = path
    }
    public func getPath() -> String? {
        return self.path
    }

    private func generateFilePath() -> URL? {
        switch self.pathType {
        case FilePathType.BUNDLE_TYPE:
            if let url = Bundle.main.path(forResource: nil, ofType: nil, inDirectory: self.getPath()) {
                return URL( fileURLWithPath:url )
            }
            break
        case FilePathType.DOCUMENT_TYPE:
            return FileManager.getDocumentsDirectoryPath( pathType: self.pathType, relative: self.path )
        default:
            break
        }
        return nil
    }

	func extractPath( filePath:URL ) -> String? {
		if let path = self.getPath() {
			if let index = filePath.absoluteString.indexOf(target: path) {
				return filePath.absoluteString.substring( from: index )
			}
		}
		return nil
	}
    
    public func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        if let path = self.getPath() {
            dict.setValue(path, forKey: "path")
        }
        if let pathType = self.getPathType() {
            dict.setValue(pathType.rawValue, forKey: "path_type")
        }
        if let filePath = self.getFilePath() {
            dict.setValue(filePath.absoluteString, forKey: "file_path")
        }
        dict.setValue(self.getID(), forKey: "id")
        
        var directories:[String] = [String]()
        for (_, file) in self.DIRECTORIES.enumerated() {
			if let directory = self.extractPath(filePath: file) {
				directories.append( directory )
			}
        }
        dict.setValue(directories, forKey: "directories")
        
        var files:[NSDictionary] = [NSDictionary]()
        for (_, file) in self.FILES.enumerated() {
            files.append(file.toDictionary())
        }
        dict.setValue(files, forKey: "files")
        
        
        return dict
    }

	func zip( toFileName:String, onProgress:@escaping((Double)->()), onSuccess:@escaping((ZipFile)->()), onFail:@escaping((String)->())) {
		var paths:[URL] = [URL]()
		for (_, file) in self.DIRECTORIES.enumerated() {
			paths.append(file)
		}
		for (_, file) in self.FILES.enumerated() {
			paths.append(file.getFilePath()!)
		}

		let filepath = FileManager.getDocumentsDirectoryPath(pathType: self.pathType)!.appendingPathComponent(toFileName)
		do {
			var isFinished = false
			try Zip.zipFiles(paths: paths, zipFilePath: filepath, password: nil, progress: { (progress) in
				if isFinished {
					return
				}

				onProgress( progress * 100 )

				if progress >= 1.0 {
					isFinished = true
					onSuccess( ZipFile( fileId:File.generateID(), document:toFileName, filePath: filepath) )
				}

			})
		} catch let error as NSError {
			onFail( error.localizedDescription )
		}

	}

	func share( onSuccess:@escaping((Bool)->()) ) {
		var paths:[URL] = [URL]()
		for (_, file) in self.DIRECTORIES.enumerated() {
			paths.append(file)
		}
		for (_, file) in self.FILES.enumerated() {
			paths.append(file.getFilePath()!)
		}

		FileManager.share(filePaths: paths, onSuccess: onSuccess )
	}


}
