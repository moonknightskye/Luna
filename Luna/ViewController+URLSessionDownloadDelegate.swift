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

        if let manager = DownloadManager.getManager(urlSession: session) {
			manager.setSuggestedFileName(suggestedFileName: downloadTask.response?.suggestedFilename)
            manager.onDownloaded( downloadedFilePath: location )
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
        if let manager = DownloadManager.getManager(urlSession: session) {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
			manager.onDownloading(progress: Double(progress * 100))
        }
        
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        
        if let manager = DownloadManager.getManager(urlSession: session) {
            var errorMessage = FileError.UNKNOWN_ERROR.localizedDescription
            if (error != nil) {
                errorMessage = (error?.localizedDescription)!
            }
			manager.remove( withError:errorMessage)
        }

        session.finishTasksAndInvalidate()
    }
    
}
