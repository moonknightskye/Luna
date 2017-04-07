//
//  DownloadFile.swift
//  Luna
//
//  Created by Mart Civil on 2017/04/04.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

public enum SystemFilePath:String {
    case DOWNLOADS      = "Downloads"
    case CACHE          = "_cache"
}

class DownloadFile: File {
    
    static var QUEUE:[DownloadFile] = [DownloadFile]();
    static var counter = 0;
    private var download_id = DownloadFile.counter
    
    private var savePath:String = SystemFilePath.DOWNLOADS.rawValue
    private var downloadTask: URLSessionDownloadTask!
    private var backgroundSession: URLSession!
    private var downloadedFilePath: URL?
    private var isOverwrite:Bool = false
    
    override init(){
        super.init()
    }
    
	public init( url:String, isOverwrite:Bool, savePath:String?=nil ) throws {
        try super.init( url:url )
        self.isOverwrite = isOverwrite
		if savePath != nil {
			self.savePath = savePath!
		}
        if !addDownloadToList() {
            throw FileError.DOWNLOAD_ALREADY_INQUEUE
        }
    }
    
    public convenience init( file:NSDictionary ) throws {
        if let pathType = file.value(forKeyPath: "path_type") as? String {
            if let filePathType = FilePathType( rawValue: pathType ) {
                switch filePathType {
                case FilePathType.URL_TYPE:
                    if let path = file.value(forKeyPath: "path") as? String {
                        let isOverwrite = file.value(forKeyPath: "isOverwrite") as? Bool ?? false
						let savePath = file.value(forKeyPath: "save_path") as? String
						try self.init( url: path, isOverwrite: isOverwrite, savePath:savePath )
                        return
                    }else {
                        throw FileError.INVALID_FILE_PARAMETERS
                    }
                default:
                    throw FileError.INVALID_FILE_PARAMETERS
                }
            }
        } else {
            throw FileError.INVALID_FILE_PARAMETERS
        }
        self.init()
    }
    
    public func setSavePath( savePath: String ) {
        self.savePath = savePath
    }
    public func getSavePath() -> String {
        return self.savePath
    }
    
    public func getURLSession() -> URLSession {
        return self.backgroundSession!
    }
    
    public override func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary( dictionary: super.toDictionary() )
        dict.setValue(self.getID(), forKey: "download_id")
        return dict
    }
    
    private func addDownloadToList() -> Bool {
        for (_, downloadFile) in DownloadFile.QUEUE.enumerated() {
            if downloadFile === self || downloadFile.getFilePath() == self.getFilePath() {
                return false
            }
        }
        DownloadFile.QUEUE.append(self)
        DownloadFile.counter += 1;
        return true
    }
    
    public class func getDownloadFile( download_id: Int ) -> DownloadFile? {
        for (_, downloadFile) in DownloadFile.QUEUE.enumerated() {
            if downloadFile.getID() == download_id {
                return downloadFile
            }
        }
        return nil
    }
    public class func getDownloadFile( urlSession: URLSession ) -> DownloadFile? {
        for (_, downloadFile) in DownloadFile.QUEUE.enumerated() {
            if downloadFile.getURLSession() === urlSession {
                return downloadFile
            }
        }
        return nil
    }
    
    func removeDownloadFile() {
        DownloadFile.removeDownloadFile(downloadFile: self)
        print("Download \(self.getID()) removed from Queue")
    }
    
    public class func removeDownloadFile( download_id:Int?=nil, downloadFile:DownloadFile?=nil ) {
        for ( index, manager) in DownloadFile.QUEUE.enumerated() {
            if download_id != nil && download_id == manager.getID(){
                DownloadFile.QUEUE.remove(at: index)
            } else if downloadFile != nil && downloadFile === manager{
                DownloadFile.QUEUE.remove(at: index)
            }
        }
    }
    
    func getID() -> Int {
        return self.download_id
    }
    
    
    public func download( onSuccess:((Bool)->()), onFail:((String)->()) ) {
        if self.getPathType() == .URL_TYPE {
            let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier! + self.getID().description)
            backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: Shared.shared.ViewController, delegateQueue: OperationQueue.main)
            if let url = self.getFilePath() {
                downloadTask = backgroundSession.downloadTask(with: url)
                downloadTask.resume()
                self.onDownload()
                onSuccess(true)
            } else {
                onFail( "Failed to set download path" )
            }
        } else {
            onFail( "Only URL Type Files can be downloaded" )
        }
    }
    
    func onDownload() {
        CommandProcessor.processOnDownload( downloadFile: self )
    }
    
    public override func move( relative:String?=nil, isOverwrite:Bool?=false, onSuccess:@escaping((URL)->()), onFail:((String)->())?=nil ) -> Bool {
        if let relativeURL = FileManager.getDocumentsDirectoryPath(pathType: .DOCUMENT_TYPE, relative: relative) {
            let file = FileManager.generateDocumentFilePath(fileName: self.getFileName()!, relativePath: relative )
            if FileManager.isExists(url: file ) {
                if isOverwrite! {
                    if !FileManager.deleteFile(filePath: file) {
                        if onFail != nil {
                            onFail!( "Unable to delete file" )
                        }
                        return false
                    }
                } else {
                    if onFail != nil {
                        onFail!( "File already exists" )
                    }
                    return false
                }
            }
            if !FileManager.isExists(url: relativeURL) {
                if !FileManager.createDirectory(absolutePath: relativeURL.path) {
                    if onFail != nil {
                        onFail!( "Failed to create folder to move to" )
                    }
                    return false
                }
            }
            if let fileName = self.getFileName() {
                return FileManager.moveFile(filePath: self.downloadedFilePath!, newFileName: fileName, relative: relative, onSuccess: { (result) in
                    print("intercept here \(result)")
                    onSuccess( result )
                }, onFail: onFail)
            }
        }
        if onFail != nil {
            onFail!( "Unable to move file" )
        }
        return false
    }
    
    func onDownloaded( downloadedFilePath: URL ) {
        self.downloadedFilePath = downloadedFilePath
        let _ = self.move(relative: self.savePath, isOverwrite: self.isOverwrite, onSuccess: { (result) in
            CommandProcessor.processOnDownloaded( downloadFile: self, downloadedFilePath: result )
        }) { (error) in
            CommandProcessor.processOnDownloaded( downloadFile: self, errorMessage: error )
        }
    }
    
    func onDownloading( progress: Double ) {
        CommandProcessor.processOnDownloading( downloadFile: self, progress: progress )
    }
}
