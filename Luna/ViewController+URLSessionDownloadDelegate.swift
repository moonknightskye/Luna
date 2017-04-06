//
//  ViewController+URLSessionDownloadDelegate.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/14.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

extension ViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        if let downloadFile = DownloadFile.getDownloadFile(urlSession: session) {
            downloadFile.onDownloaded( downloadedFilePath: location )
//            if let fileName = downloadFile.getFileName() {
//                
//                let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//                let documentDirectoryPath:String = path[0]
//                let fileManager = FileManager()
//                let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/\(fileName)"))
//                
//                if fileManager.fileExists(atPath: destinationURLForFile.path){
//                    print( destinationURLForFile.path )
//                }
//                else{
//                    do {
//                        try fileManager.moveItem(at: location, to: destinationURLForFile)
//                        // show file
//                        print( destinationURLForFile.path )
//                    }catch{
//                        print("An error occurred while moving file to destination url")
//                    }
//                }
//            }
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
        if let downloadFile = DownloadFile.getDownloadFile(urlSession: session) {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            downloadFile.onDownloading(progress: Double(progress * 100))
        }
        
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            if let downloadFile = DownloadFile.getDownloadFile(urlSession: session) {
                downloadFile.removeDownloadFile()
            }
            
        }
    }
    
}
