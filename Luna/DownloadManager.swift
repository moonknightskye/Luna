//
//  DownloadManager.swift
//  Luna
//
//  Created by 志美瑠 真斗 on 2017/04/10.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

class DownloadManager {

	static var QUEUE:[DownloadManager] = [DownloadManager]();
	static var counter = 0;
	private var download_id = DownloadManager.counter
	private var downloadFile:File!

	private var downloadTask: URLSessionDownloadTask!
	private var backgroundSession: URLSession!
    private var savePath:String!
    private var isOverwrite:Bool!

    public init( file: File, savePath:String?=SystemFilePath.DOWNLOADS.rawValue, isOverwrite:Bool?=false ) throws {
		if file.getPathType() == FilePathType.URL_TYPE {
			self.downloadFile = file
            self.savePath = savePath
            self.isOverwrite = isOverwrite
            
			for (_, manager) in DownloadManager.QUEUE.enumerated() {
				if manager.getFile().getFilePath() == self.getFile().getFilePath() {
					throw FileError.DOWNLOAD_ALREADY_INQUEUE
				}
			}

            let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier!)
            backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: Shared.shared.ViewController, delegateQueue: OperationQueue.main)
            if let url = file.getFilePath() {
                downloadTask = backgroundSession.downloadTask(with: url)
                downloadTask.resume()
            } else {
                throw FileError.INVALID_FILE_PARAMETERS
            }
            
			DownloadManager.QUEUE.append(self)
			DownloadManager.counter += 1;
		} else {
			throw FileError.ONLY_URL_TYPE
		}
	}
    
    public class func getManager( path: String ) -> DownloadManager? {
        for (_, manager) in DownloadManager.QUEUE.enumerated() {
            if let urlPath = manager.getFile().getFilePath()?.absoluteString {
                if urlPath == path {
                    return manager
                }
            }
        }
        return nil
    }
    
//    public class func getManager( download_id: Int ) -> DownloadManager? {
//        for (_, manager) in DownloadManager.QUEUE.enumerated() {
//            if manager.getID() == download_id {
//                return manager
//            }
//        }
//        return nil
//    }
    public class func getManager( urlSession: URLSession ) -> DownloadManager? {
        for (_, manager) in DownloadManager.QUEUE.enumerated() {
            if manager.getURLSession() === urlSession {
                return manager
            }
        }
        return nil
    }
    
    func removeDownloadManager() {
        DownloadManager.removeDownloadFile(manager: self)
        print("Download \(self.getID()) removed from Queue")
    }
    public class func removeDownloadFile( download_id:Int?=nil, manager:DownloadManager?=nil ) {
        for ( index, DLManager) in DownloadManager.QUEUE.enumerated() {
            if download_id != nil && download_id == DLManager.getID(){
                DownloadManager.QUEUE.remove(at: index)
            } else if manager != nil && manager === DLManager{
                DownloadManager.QUEUE.remove(at: index)
            }
        }
    }
    
    func processDownloadedFile( path: URL, onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ) {
        if let relativeURL = FileManager.getDocumentsDirectoryPath(pathType: .DOCUMENT_TYPE, relative: self.savePath) {
            let file = FileManager.generateDocumentFilePath(fileName: self.getFile().getFileName()!, relativePath: self.savePath )
            if FileManager.isExists(url: file ) {
                if isOverwrite! {
                    if !FileManager.deleteFile(filePath: file) {
                        onFail( "Unable to delete file" )
                    }
                } else {
                    onFail( "File already exists" )
                }
            }
            if !FileManager.isExists(url: relativeURL) {
                if !FileManager.createDirectory(absolutePath: relativeURL.path) {
                    onFail( "Failed to create folder to move to" )
                }
            }
            if let fileName = self.getFile().getFileName() {
                let _ = FileManager.moveFile(filePath: path, newFileName: fileName, relative: self.savePath, onSuccess: { (result) in
                    onSuccess( result.absoluteString )
                }, onFail: onFail)
            }
        }
        onFail( "Something went wrong" )
    }
    
    func getID() -> Int {
        return self.download_id
    }

	public func getFile() -> File {
		return self.downloadFile
	}
    
    public func getURLSession() -> URLSession {
        return self.backgroundSession!
    }
}


