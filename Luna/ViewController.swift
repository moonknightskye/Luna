//
//  ViewController.swift
//  Luna
//
//  Created by Mart Civil on 2017/01/18.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import UIKit
import AVFoundation
//import CoreLocation http://www.techotopia.com/index.php/A_Swift_Example_iOS_8_Location_Application
//import CloudKit

class ViewController: UIViewController, UINavigationControllerDelegate  {
    
    private let isTest = false
    
    private func loadTest() {
        let parameter = NSMutableDictionary()
        parameter.setValue( "index.html", forKey: "filename")
        parameter.setValue( "resource", forKey: "path")
        parameter.setValue( "bundle", forKey: "path_type")
        
        let commandGetFile = Command( commandCode: CommandCode.GET_HTML_FILE, parameter: parameter )
        commandGetFile.onResolve { ( htmlFile ) in
            self.loadStartupPage(htmlFile: htmlFile as! HtmlFile)
        }
        CommandProcessor.queue(command: commandGetFile)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Shared.shared.ViewController = self
        
        SettingsPage.instance.attachListeners()
        
        print( SystemSettings.instance.getSystemSettings() )
        
        
        if isTest {
            loadTest()
        } else {
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
        }
        
        


        //request1()
//        RecordAudio.instance.checkPermission(onSuccess: { (result)  in
//            if result {
//                RecordAudio.instance.startRecording()
//                let _ = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.finishRecording), userInfo: nil, repeats: false)
//            }
//        }) { (error) in
//            print(error)
//        }
        
    }

//    func finishRecording() {
//        RecordAudio.instance.stopRecording()
//    }
    
//    private func request1() {
//        let parameters = NSMutableDictionary()
//        parameters.setValue( "POST", forKey: "method")
//        parameters.setValue( "https://api.recaius.jp/auth/v2/tokens", forKey: "url")
//        let headers = NSMutableDictionary()
//        headers.setValue( "application/json", forKey: "Content-Type")
//        headers.setValue( "application/json", forKey: "Accept")
//        parameters.setValue( headers, forKey: "headers")
//        let data = NSMutableDictionary()
//        let spjp = NSMutableDictionary()
//        spjp.setValue( "sfdcjpdemo01_MA9N7kF3h9", forKey: "service_id")
//        spjp.setValue( "sfdc1234", forKey: "password")
//        let spen = NSMutableDictionary()
//        spen.setValue( "sfdcjpdemo01_MA9N7kF3h9_enUS", forKey: "service_id")
//        spen.setValue( "sfdc1234", forKey: "password")
//        let spch = NSMutableDictionary()
//        spch.setValue( "sfdcjpdemo01_MA9N7kF3h9_zhCN", forKey: "service_id")
//        spch.setValue( "sfdc1234", forKey: "password")
//        data.setValue( spjp, forKey: "speech_recog_jaJP")
//        data.setValue( spen, forKey: "speech_recog_enUS")
//        data.setValue( spch, forKey: "speech_recog_zhCN")
//        data.setValue( 300, forKey: "expiry_sec")
//        parameters.setValue( data, forKey: "data")
//        let command = Command( commandCode: CommandCode.HTTP_POST, parameter: parameters )
//        command.onResolve { ( result ) in
//            self.request2(token: result as! NSDictionary)
//        }
//        CommandProcessor.queue(command: command)
//    }
//    
//    private func request2( token:NSDictionary ) {
//        let token = token.value(forKeyPath: "token") as! String
//        
//        let parameters = NSMutableDictionary()
//        parameters.setValue( "POST", forKey: "method")
//        parameters.setValue( "https://api.recaius.jp/asr/v2/voices", forKey: "url")
//        let headers = NSMutableDictionary()
//        headers.setValue( "application/json", forKey: "Content-Type")
//        headers.setValue( "application/json", forKey: "Accept")
//        headers.setValue( token, forKey: "X-Token")
//        parameters.setValue( headers, forKey: "headers")
//        let data = NSMutableDictionary()
//        data.setValue( 300, forKey: "energy_threshold")
//        data.setValue( 1, forKey: "model_id")
//        data.setValue( "audio/x-linear", forKey: "audio_type")
//        data.setValue( false, forKey: "push_to_talk")
//        data.setValue( "one_best", forKey: "result_type")
//        data.setValue( 1, forKey: "data_log")
//        data.setValue( "Hello World!", forKey: "comment")
//        data.setValue( 1, forKey: "result_count")
//        parameters.setValue( data, forKey: "data")
//        let command = Command( commandCode: CommandCode.HTTP_POST, parameter: parameters )
//        command.onResolve { ( result ) in
//            print(result)
//            
//            let uuid = (result as! NSDictionary).value(forKeyPath: "uuid") as! String
//            do {
//                let audio = try File(fileId: File.generateID(), bundle: "speech.wav", path: "resource/img")
//                //print(audio.getFilePath())
//                self.request3(dataUrl:audio.getFilePath()!, data: audio.getFile()!, tokenid: token, uiid: uuid)
//            } catch {
//                print("ERRROR")
//            }
//            
//            
//        }
//        CommandProcessor.queue(command: command)
//    }
//    
//    func request3( dataUrl:URL, data:Data, tokenid:String, uiid:String ) {
//        let voice_id = 1;
//        let parameters = NSMutableDictionary()
//        parameters.setValue( "PUT", forKey: "method")
//        parameters.setValue( "https://api.recaius.jp/asr/v2/voices/" + uiid, forKey: "url")
//        let headers = NSMutableDictionary()
//        headers.setValue( "multipart/form-data", forKey: "Content-Type")
//        headers.setValue( tokenid, forKey: "X-Token")
//        parameters.setValue( headers, forKey: "headers")
//        
//        let multipart = NSMutableDictionary()
//        multipart.setValue( dataUrl, forKey: "dataUrl")
//        multipart.setValue( data, forKey: "data")
//        let pmtrs = NSMutableDictionary()
//        pmtrs.setValue(voice_id, forKey: "voiceid")
//        multipart.setValue( pmtrs, forKey: "parameters")
//        multipart.setValue( "application/octet-stream", forKey: "mimeType")
//        multipart.setValue( "test.wav", forKey: "filename")
//        parameters.setValue( multipart, forKey: "multipart")
//        
//        let command = Command( commandCode: CommandCode.HTTP_POST, parameter: parameters )
//        command.onResolve { ( result ) in
//            print(result)
//        }
//        command.onReject { (message) in
//            print("HELLLLOOOOOOOOO")
//            print(message)
//        }
//        CommandProcessor.queue(command: command)
//    }

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

