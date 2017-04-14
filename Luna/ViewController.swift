//
//  ViewController.swift
//  Luna
//
//  Created by Mart Civil on 2017/01/18.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit

class ViewController: UIViewController, UINavigationControllerDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        Shared.shared.ViewController = self
        
        
        var parameter = NSMutableDictionary()
        parameter.setValue( "index.html", forKey: "filename")
        parameter.setValue( "resource", forKey: "path")
        parameter.setValue( "bundle", forKey: "path_type")
        
//        parameter.setValue( "http://techslides.com/demos/video/dragdrop-video-screenshot.html", forKey: "path")
//        parameter.setValue( "url", forKey: "path_type")
        let commandGetFile = Command( commandCode: CommandCode.GET_HTML_FILE, parameter: parameter )
        
        commandGetFile.onResolve { ( htmlFile ) in
            parameter = NSMutableDictionary()
            parameter.setValue( htmlFile, forKey: "html_file")
            let command = Command(commandCode: CommandCode.NEW_WEB_VIEW, parameter: parameter)
            command.onResolve { (webview_id) in
//                let commandOnLoading = Command(commandCode: CommandCode.WEB_VIEW_ONLOADING, targetWebViewID: webview_id as? Int)
//                commandOnLoading.onUpdate(fn: { (progress) in
//                    print( "Loading... \(progress)%" )
//                })
//                CommandProcessor.queue(command: commandOnLoading)
                
                CommandProcessor.queue(command:
                    Command( commandCode: CommandCode.LOAD_WEB_VIEW, targetWebViewID: webview_id as? Int )
                )
                
            }
            command.onReject { (message) in
                print( message )
            }
            CommandProcessor.queue(command: command)
            
        }
        CommandProcessor.queue(command: commandGetFile)
        

//        do {
//            let filecol = try FileCollection( relative:"unzipfolder", pathType: FilePathType.DOCUMENT_TYPE);
//            try filecol.zip(fileName: "matozipped.zip")
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
        //print(UserDefaults.standard.value(forKeyPath: "name_preference"))
        
        
        
//        file:///private/var/mobile/Library/Mobile%20Documents/iCloud~com~salesforce~Luna/Luna/
//        file:///private/var/mobile/Library/Mobile%20Documents/iCloud~com~salesforce~Luna/Luna/.spiderman.jpg.icloud
//        file:///private/var/mobile/Library/Mobile%20Documents/iCloud~com~salesforce~Luna/Luna/.test.txt.icloud
//        read error
//        read error
//        ERROR: File does not exists.
        
        
        //README!!!!
        //https://developer.apple.com/reference/foundation/filemanager/1413989-setubiquitous
        //Sets whether the item at the specified URL should be stored in the cloud.
        //func setUbiquitous(_ flag: Bool, itemAt url: URL, destinationURL: URL) throws
        //Specify true to move the item to iCloud or false to remove it from iCloud (if it is there currently).
        
        if let iCloudDocumentURL = FileManager.getDocumentsDirectoryPath(pathType: .ICLOUD_TYPE, relative: "Luna") {
            print(iCloudDocumentURL)
            do {
                
                if let fileCollection = FileManager.getDocumentsFileList( path: iCloudDocumentURL ) {
                    for (_, file) in fileCollection.enumerated() {
                        print(file)
                    }
                }
                
                let image = iCloudDocumentURL.appendingPathComponent("spiderman.jpg")
                do {
                    let imagefile = try UIImage(data: Data(contentsOf: image))
                    //DispatchQueue.main.async(execute: {
                    print( imagefile ?? "none" )

                } catch let error as NSError{
                    print("[ERROR] \(error.localizedDescription)")

                }
                
                //DispatchQueue.global().async(execute: {
                    let filePath = iCloudDocumentURL.appendingPathComponent("test.txt")
                    do {
                        let readText = try String(contentsOf: filePath)
                        //DispatchQueue.main.async(execute: {
                            print(readText)
                            print(filePath)
                        //})
                    } catch {
                        print("read error")
                    }

                //})
                
                let file = try File(document:"spiderman.jpg")
                
                //DispatchQueue.global().async(execute: {
                let fileURL = iCloudDocumentURL.appendingPathComponent( file.getFileName()! )
                let result = FileManager.default.createFile(atPath: fileURL.path, contents: file.getFile()!, attributes: nil)
                print("RESULT: \(result)")
                //})
                
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
            }
            
            
        } else {
            print("iCloud is not Working")
        }

    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

