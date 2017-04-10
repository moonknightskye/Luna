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
            let file = manager.getFile()
            if let suggestedFilename = downloadTask.response?.suggestedFilename {
                file.setFileName(fileName: suggestedFilename)
            }
            file.onDownloaded( downloadedFilePath: location )
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
        if let manager = DownloadManager.getManager(urlSession: session) {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            manager.getFile().onDownloading(progress: Double(progress * 100))
        }
        
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        
        if let manager = DownloadManager.getManager(urlSession: session) {
            var errorMessage = "The file has already been downloaded"
            if (error != nil) {
                errorMessage = (error?.localizedDescription)!
            }
            CommandProcessor.getCommand(commandCode: CommandCode.ONDOWNLOADED) { (command) in
                if let dmanager = CommandProcessor.getDownloadManager(command: command) {
                    if manager === dmanager {
                        command.reject(errorMessage: errorMessage)
                    }
                }
            }
            CommandProcessor.getCommand(commandCode: CommandCode.ONDOWNLOADING) { (command) in
                if let dmanager = CommandProcessor.getDownloadManager(command: command) {
                    if manager === dmanager {
                        command.reject(errorMessage: errorMessage)
                    }
                }
            }
            manager.removeDownloadManager()
        }

        session.finishTasksAndInvalidate()
    }
    
}
