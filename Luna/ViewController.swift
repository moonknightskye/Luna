//
//  ViewController.swift
//  Luna
//
//  Created by Mart Civil on 2017/01/18.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
//import CloudKit

class ViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate  {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Shared.shared.ViewController = self
        
        SettingsPage.instance.attachListeners()
        
        if UserSettings.instance.isShowSplashScreen() {
            let parameter = NSMutableDictionary()
            parameter.setValue( "splash.html", forKey: "filename")
            parameter.setValue( "resource", forKey: "path")
            parameter.setValue( "bundle", forKey: "path_type")
            
            let commandGetFile = Command( commandCode: CommandCode.GET_HTML_FILE, parameter: parameter )
            commandGetFile.onResolve { ( htmlFile ) in
                self.loadStartupPage(htmlFile: htmlFile as! HtmlFile)
            }
            CommandProcessor.queue(command: commandGetFile)
        } else {
            if let htmlFile = UserSettings.instance.getStartupHtmlFile() {
                self.loadStartupPage(htmlFile: htmlFile)
            } else {
                let htmlFile = SettingsPage.instance.getPage()
                self.loadStartupPage(htmlFile: htmlFile, errorMessage: "File does not exists.")
            }
        }
        
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        

    }
    
    private func loadStartupPage( htmlFile: HtmlFile, errorMessage:String?=nil ) {
        let parameter = NSMutableDictionary()
        parameter.setValue( htmlFile, forKey: "html_file")
        let property = NSMutableDictionary()
        property.setValue( CGFloat(0.0), forKey: "opacity")
        parameter.setValue( property, forKey: "property")

        let command = Command(commandCode: CommandCode.NEW_WEB_VIEW, parameter: parameter)
        command.onResolve { (webview_id) in
            let cmdproperty = NSMutableDictionary()
            cmdproperty.setValue( webview_id, forKey: "webview_id")
            
            let commandOnLoading = Command(commandCode: CommandCode.WEB_VIEW_ONLOADING, targetWebViewID: webview_id as? Int, parameter: cmdproperty)
            commandOnLoading.onUpdate(fn: { (progress) in
                print( "Loading... \(progress)%" )
            })
            CommandProcessor.queue(command: commandOnLoading)
            
            let commandOnLoaded = Command(commandCode: CommandCode.WEB_VIEW_ONLOADED, targetWebViewID: webview_id as? Int, parameter: cmdproperty)
            commandOnLoaded.onUpdate(fn: { (result) in
                
                if let isSuccess = (result as AnyObject).value(forKeyPath: "success") as? Bool {
                    
                    if isSuccess {
                        let setpropparam = NSMutableDictionary()
                        let propparam = NSMutableDictionary()
                        propparam.setValue( CGFloat(1.0), forKey: "opacity")
                        let animaparam = NSMutableDictionary()
                        animaparam.setValue( Double(0.6), forKey: "duration")
                        setpropparam.setValue( propparam, forKey: "property")
                        setpropparam.setValue( animaparam, forKey: "animation")
                        let commandSetProperty = Command(commandCode: CommandCode.ANIMATE_WEB_VIEW, targetWebViewID: Int(webview_id as! Int), parameter: setpropparam)
                        commandSetProperty.onResolve(fn: { (result) in
                            
                            if errorMessage != nil {
                                let messageprop = NSMutableDictionary()
                                messageprop.setValue( errorMessage!, forKey: "message")
                                messageprop.setValue( false, forKey: "isSendToAll")
                                messageprop.setValue( true, forKey: "isSendUntilRecieved")
                                
                                
                                let commandSendMessage = Command(commandCode: CommandCode.WEB_VIEW_POSTMESSAGE, targetWebViewID: Int(webview_id as! Int), parameter: messageprop)
                                CommandProcessor.queue(command: commandSendMessage)
                            }
                        })
                        CommandProcessor.queue(command: commandSetProperty)
                    } else {
                        if let errorMsg = (result as AnyObject).value(forKeyPath: "message") as? String {
                            self.loadStartupPage(htmlFile: SettingsPage.instance.getPage(), errorMessage: errorMsg)
                        }
                    }
                }
            })
            CommandProcessor.queue(command: commandOnLoaded)
            
            CommandProcessor.queue(command:
                Command( commandCode: CommandCode.LOAD_WEB_VIEW, targetWebViewID: webview_id as? Int )
            )
        }
        command.onReject { (message) in
            print( message )
        }
        CommandProcessor.queue(command: command)
    }
    
    func screenEdgeSwipedOneFinger(_ recognizer: UIGestureRecognizer) {
        if let swipeGesture = recognizer as? UISwipeGestureRecognizer {
            CommandProcessor.processSwipeGesture(swipeDirection: swipeGesture.direction, touchesRequired: 1)
        }
    }

    func screenEdgeSwipedTwoFingers(_ recognizer: UIGestureRecognizer) {
        if let swipeGesture = recognizer as? UISwipeGestureRecognizer {
            CommandProcessor.processSwipeGesture(swipeDirection: swipeGesture.direction, touchesRequired: 2)
        }
    }

    func screenEdgeSwipedThreeFingers(_ recognizer: UIGestureRecognizer) {
        if let swipeGesture = recognizer as? UISwipeGestureRecognizer {
            CommandProcessor.processSwipeGesture(swipeDirection: swipeGesture.direction, touchesRequired: 3)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            CommandProcessor.processShakeBegin()
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            CommandProcessor.processShakeEnd()
        }
    }
    
    override func motionCancelled(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            CommandProcessor.processShakeCancelled()
        }
    }
}




//parameter.setValue( "https://login.salesforce.com/?un=dem%40sfcloud.com&pw=salesforce1", forKey: "path")
//parameter.setValue( "https://matodemo-06-com-developer-edition.ap2.force.com/luna/s/", forKey: "path")
//parameter.setValue( "https://login.salesforce.com/?un=mato@demo06.jp&pw=mattaku85", forKey: "path")
//parameter.setValue( "https://matodemo-06-developer-edition.ap2.force.com/", forKey: "path")
//parameter.setValue( "url", forKey: "path_type")


//        do {
//            let filecol = try FileCollection( relative:"zip3folders", pathType: FilePathType.DOCUMENT_TYPE);
//            filecol.zip(toFileName: "matozip.zip", onProgress: { (progress) in
//                print( progress )
//            }, onSuccess: { (zipFile) in
//                print(zipFile.toDictionary())
//            }, onFail: { (errorMessage) in
//                print(errorMessage)
//            })
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

//        if let iCloudDocumentURL = FileManager.getDocumentsDirectoryPath(pathType: .ICLOUD_TYPE, relative: "Luna") {
//            print(iCloudDocumentURL)
//            do {
//
//                if let fileCollection = FileManager.getDocumentsFileList( path: iCloudDocumentURL ) {
//                    for (_, file) in fileCollection.enumerated() {
//                        print(file)
//                    }
//                }
//
//                let image = iCloudDocumentURL.appendingPathComponent("spiderman.jpg")
//                do {
//                    let imagefile = try UIImage(data: Data(contentsOf: image))
//                    //DispatchQueue.main.async(execute: {
//                    print( imagefile ?? "none" )
//
//                } catch let error as NSError{
//                    print("[ERROR] \(error.localizedDescription)")
//
//                }
//
//                //DispatchQueue.global().async(execute: {
//                    let filePath = iCloudDocumentURL.appendingPathComponent("test.txt")
//                    do {
//                        let readText = try String(contentsOf: filePath)
//                        //DispatchQueue.main.async(execute: {
//                            print(readText)
//                            print(filePath)
//                        //})
//                    } catch {
//                        print("read error")
//                    }
//
//                //})
//
//                let file = try File(document:"spiderman.jpg")
//
//                //DispatchQueue.global().async(execute: {
//                let fileURL = iCloudDocumentURL.appendingPathComponent( file.getFileName()! )
//                let result = FileManager.default.createFile(atPath: fileURL.path, contents: file.getFile()!, attributes: nil)
//                print("RESULT: \(result)")
//                //})
//
//            } catch let error as NSError {
//                print("ERROR: \(error.localizedDescription)")
//            }
//
//
//        } else {
//            print("iCloud is not Working")
//        }

