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
            if let fileName = downloadTask.response?.suggestedFilename {
                downloadFile.setFileName(fileName: fileName)
            }
            downloadFile.onDownloaded( downloadedFilePath: location )
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
        if let downloadFile = DownloadFile.getDownloadFile(urlSession: session) {
            if (error != nil) {
                CommandProcessor.getCommand(commandCode: CommandCode.ONDOWNLOADED) { (command) in
                    if let innerDownloadFile = CommandProcessor.getDownloadFile(command: command) {
                        if innerDownloadFile.getID() == downloadFile.getID() {
                            command.reject(errorMessage: error!.localizedDescription)
                        }
                    }
                }
                CommandProcessor.getCommand(commandCode: CommandCode.ONDOWNLOADING) { (command) in
                    if let innerDownloadFile = CommandProcessor.getDownloadFile(command: command) {
                        if innerDownloadFile.getID() == downloadFile.getID() {
                            command.reject(errorMessage: error!.localizedDescription)
                        }
                    }
                }
            }
            downloadFile.removeDownloadFile()
        }
        session.finishTasksAndInvalidate()
    }
    
}
