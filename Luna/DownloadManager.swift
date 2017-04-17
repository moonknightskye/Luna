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
    private var download_id:Int!
	private var downloadFile:File!

	private var downloadLink:URL!
	private var downloadedFilePath:URL?
	private var suggestedFilename:String?
	private var downloadTask: URLSessionDownloadTask!
	private var backgroundSession: URLSession!
    private var savePath:String!
    private var isOverwrite:Bool!

    public init( file: File, savePath:String?, isOverwrite:Bool?=false ) throws {
		if file.getPathType() == FilePathType.URL_TYPE {

			self.downloadFile = file
			self.downloadLink = file.getFilePath()
            self.savePath = savePath ?? SystemFilePath.DOWNLOADS.rawValue
            self.isOverwrite = isOverwrite

			if let _ = DownloadManager.getManager(download_id: self.getFile().getID()) {
				throw FileError.DOWNLOAD_ALREADY_INQUEUE
			}

            self.download_id = self.getFile().getID()
			DownloadManager.QUEUE.append(self)

            let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier! + self.getID().description)
			backgroundSessionConfiguration.allowsCellularAccess = Shared.shared.allowsCellularAccess
            backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: Shared.shared.ViewController, delegateQueue: OperationQueue.main)

			downloadTask = backgroundSession.downloadTask(with: self.downloadLink)
			downloadTask.resume()

		} else {
			throw FileError.ONLY_URL_TYPE
		}
	}
    
    public class func getManager( download_id: Int ) -> DownloadManager? {
        for (_, manager) in DownloadManager.QUEUE.enumerated() {
            if manager.getID() == download_id {
                return manager
            }
        }
        return nil
    }
    
//    public class func getManager( path: String ) -> DownloadManager? {
//        for (_, manager) in DownloadManager.QUEUE.enumerated() {
//			if manager.getDownloadLink().absoluteString == path {
//				return manager
//			}
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
    
	func remove( withError:String ) {
		DownloadManager.remove(manager: self, withError:withError)
        print("Download \(self.getID()) removed from Queue")
    }
	public class func remove( manager:DownloadManager, withError:String ) {
		CommandProcessor.processDownloadOnError(manager: manager, commandCode: .ONDOWNLOAD, errorMessage: withError)
		CommandProcessor.processDownloadOnError(manager: manager, commandCode: .ONDOWNLOADED, errorMessage: withError)
		CommandProcessor.processDownloadOnError(manager: manager, commandCode: .ONDOWNLOADING, errorMessage: withError)

        for ( index, DLManager) in DownloadManager.QUEUE.enumerated() {
            if manager === DLManager{
                DownloadManager.QUEUE.remove(at: index)
            }
        }
    }
    
    func processDownloadedFile( onSuccess:@escaping ((URL)->()), onFail:@escaping ((String)->()) ) {
        if let relativeURL = FileManager.getDocumentsDirectoryPath(pathType: .DOCUMENT_TYPE, relative: self.savePath) {
			if let file = FileManager.generateDocumentFilePath(fileName: self.suggestedFilename!, relativePath: self.savePath ) {
				if FileManager.isExists(url: file ) {
					if isOverwrite! {
						if !FileManager.deleteFile(filePath: file) {
							onFail( FileError.CANNOT_DELETE.localizedDescription )
						}
					} else {
						onFail( FileError.ALREADY_EXISTS.localizedDescription )
					}
				}
			}
            if !FileManager.isExists(url: relativeURL) {
                if !FileManager.createDirectory(absolutePath: relativeURL.path) {
                    onFail( FileError.CANNOT_CREATE.localizedDescription )
                }
            }
			let _ = FileManager.moveFile(filePath: self.downloadedFilePath!, newFileName: self.suggestedFilename, relative: self.savePath, onSuccess: { (result) in
				onSuccess( result )
			}, onFail: onFail)
        }
        onFail( FileError.UNKNOWN_ERROR.localizedDescription )
    }

	func onDownload() {
		CommandProcessor.processOnDownload( manager: self )
	}

	func onDownloaded( downloadedFilePath:URL ) {
		self.downloadedFilePath = downloadedFilePath

		processDownloadedFile( onSuccess: { (result) in
			self.downloadFile.setFileName(fileName: self.suggestedFilename!)
			self.downloadFile.setFilePath(filePath: result)
			self.downloadFile.setPath(path: self.savePath)
			self.downloadFile.setPathType(pathType: .DOCUMENT_TYPE)
			CommandProcessor.processOnDownloaded( manager: self, result: self.downloadFile.toDictionary() )
		}, onFail: { (errorMessage) in
			CommandProcessor.processOnDownloaded( manager: self, errorMessage:errorMessage )
		})	}

	func onDownloading( progress:Double ) {
		CommandProcessor.processOnDownloading( manager: self, progress: progress )
	}

	func setSuggestedFileName( suggestedFileName: String?=nil ) {
		self.suggestedFilename = suggestedFileName
	}

	func getDownloadLink() -> URL {
		return self.downloadLink
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


