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
    
    private var FILES:[File] = [File]()
    private var DIRECTORIES:[URL] = [URL]()
    private var path:String = SystemFilePath.DOCUMENT.rawValue
    private var pathType:FilePathType = FilePathType.DOCUMENT_TYPE
    private var filePath:URL?
    
    
    init( relative:String, pathType:FilePathType?=nil, filePath:URL?=nil ) throws {
		self.path = relative

        if pathType != nil {
            self.pathType = pathType!
        }
        if filePath != nil {
            self.filePath = filePath!
        } else {
            self.filePath = FileManager.getDocumentsDirectoryPath( pathType: self.pathType, relative: self.path )
        }

		if !FileManager.isExists(url: self.filePath!) {
			throw FileError.INEXISTENT
		}
        
        if let fileCollection = FileManager.getDocumentsFileList( path: self.filePath! ) {
            for (_, file) in fileCollection.enumerated() {
                if file.absoluteString.endsWith(string: "/") {
                    self.DIRECTORIES.append(file)
                } else {
					var fileObj:File?
					let fileExt = File.getFileExtension(filename: file.absoluteString )
					switch( File.getFileType(fileExt:fileExt) ) {
                    case .ZIP_FILE:
						fileObj = ZipFile( path: self.path, filePath: file )
						break
					case .IMAGE_FILE:
						fileObj = ImageFile( path: self.path, filePath: file )
						break
					case .VIDEO_FILE:
						fileObj = VideoFile( path: self.path, filePath: file )
						break
					case .HTML_FILE:
						fileObj = HtmlFile( path: self.path, filePath: file )
						break
                    default:
						fileObj = File( path: self.path, filePath: file )
                        break
                    }
                    self.FILES.append( fileObj! )
                }
            }
        }
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
					onSuccess( ZipFile(document:toFileName, filePath: filepath) )
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

		let activityVC = UIActivityViewController(activityItems: paths, applicationActivities: nil)
		Shared.shared.ViewController.present(activityVC, animated: true, completion: {
			onSuccess( true )
		})
	}


}
