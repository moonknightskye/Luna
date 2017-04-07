//
//  CommandProcessor.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/01.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UIKit
import Photos
//struct CommandC {
//    static let someNotification = "TEST"
//}

class CommandProcessor {
    
    private static var QUEUE:[Command] = [Command]();
    
    public class func queue( command: Command ) {
        CommandProcessor.QUEUE.append( command )
        
        switch command.getCommandCode() {
        case CommandCode.NEW_WEB_VIEW:
            processNewWebView( command: command )
            break
        case CommandCode.LOAD_WEB_VIEW:
            processLoadWebView( command: command )
            break
        case CommandCode.ANIMATE_WEB_VIEW:
            processAnimateWebView( command: command )
            break
        case CommandCode.WEB_VIEW_ONLOAD,
             CommandCode.WEB_VIEW_ONLOADED,
             CommandCode.WEB_VIEW_ONLOADING:
            checkWebViewEvent( command: command )
            break
        case CommandCode.CLOSE_WEB_VIEW:
            processCloseWebView( command: command )
            break
        case CommandCode.TAKE_PHOTO:
            checkTakePhoto( command: command )
            break
        case CommandCode.GET_FILE:
            processGetFile( command: command )
            break
        case CommandCode.GET_HTML_FILE:
            processGetHTMLFile( command: command )
            break
        case CommandCode.GET_BASE64_IMAGE:
//            processGetBase64Image( command: command )
            break
        case CommandCode.GET_EXIF_IMAGE:
            processGetExifImage( command: command )
            break
        case CommandCode.GET_BASE64_BINARY:
            processGetBase64Binary( command: command )
            break
        case CommandCode.GET_BASE64_RESIZED:
            processGetBase64Resized( command: command )
            break
        case CommandCode.GET_VIDEO_BASE64_BINARY:
            processGetVideoBase64Binary( command: command )
            break
        case CommandCode.GET_VIDEO:
            processGetVideo( command: command )
            break
        case CommandCode.NEW_AV_PLAYER:
            processNewAVPlayer( command: command )
            break
        case CommandCode.APPEND_AV_PLAYER:
            processAppendAVPlayer( command: command )
            break
        case CommandCode.AV_PLAYER_PLAY:
            processAVPlayerPlay( command: command )
            break
        case CommandCode.AV_PLAYER_PAUSE:
            processAVPlayerPause( command: command )
            break
        case CommandCode.AV_PLAYER_SEEK:
            processAVPlayerSeek( command: command )
            break
        case CommandCode.TAKE_VIDEO:
            checkTakeVideo( command: command )
            break
        case CommandCode.MEDIA_PICKER:
            checkMediaPicker( command: command )
            break
        case CommandCode.CHANGE_ICON:
            proccessChangeIcon(command: command)
            break
        case CommandCode.GET_VIDEO_FILE:
            processGetVideoFile( command: command )
            break
		case CommandCode.DOWNLOAD:
			processDownloadFile( command: command )
			break
        case CommandCode.NEW_DOWNLOAD_FILE:
            processNewDownloadFile( command: command )
            break
        case CommandCode.ONDOWNLOAD,
             CommandCode.ONDOWNLOADING,
             CommandCode.ONDOWNLOADED:
            checkDownloadEvent( command: command )
            break
        case CommandCode.MOVE_FILE:
            processMoveFile( command: command )
            break
        case CommandCode.RENAME_FILE:
            processRenameFile( command: command )
            break
        case CommandCode.COPY_FILE:
            processCopyFile( command: command )
            break
        case CommandCode.DELETE_FILE:
            processDeleteFile( command: command )
            break
        default:
            print( "[ERROR] Invalid Command Code: \(command.getCommandCode())" )
            command.reject(errorMessage: "Invalid Command Code: \(command.getCommandCode())")
            return
        }
    }
    
    public class func getWebViewManager( command: Command ) -> WebViewManager? {
        if let wkmanager = WebViewManager.getManager(webview_id: command.getTargetWebViewID()) {
            return wkmanager
        } else {
            command.reject( errorMessage: "[ERROR] No webview with ID of \(command.getTargetWebViewID()) found." )
        }
        return nil
    }
    
    public class func getAVPlayerManager( command: Command ) -> AVPlayerManager? {
        if let avplayerID = (command.getParameter() as AnyObject).value(forKeyPath: "avplayer_id") as? Int {
            if let avmanager = AVPlayerManager.getManager(avplayer_id: avplayerID) {
                return avmanager
            } else {
                command.reject( errorMessage: "[ERROR] No avplayer with ID of \(avplayerID) found." )
                return nil
            }
        }
        command.reject( errorMessage: "[ERROR] avplayer_id is not existent" )
        return nil
    }
    
    public class func getDownloadFile( command: Command ) -> DownloadFile? {
        if let downloadID = (command.getParameter() as AnyObject).value(forKeyPath: "download_id") as? Int {
            if let downloadFile = DownloadFile.getDownloadFile(download_id: downloadID) {
                return downloadFile
            }
        }
        command.reject( errorMessage: "[ERROR] Download File does not exists" )
        return nil
    }
    
    public class func getQueue() -> [Command] {
        return CommandProcessor.QUEUE
    }
    public class func getCommand( commandCode:CommandCode, ifFound:((Command)->()) ) {
        for (_, command) in CommandProcessor.getQueue().enumerated() {
            if command.getCommandCode() == commandCode {
                ifFound( command )
            }
        }
    }
    
    
    public class func remove( command: Command ) {
        for (index, item) in CommandProcessor.QUEUE.enumerated() {
            if( item === command) {
                CommandProcessor.QUEUE.remove(at: index)
                print( "[INFO][REMOVED] COMMAND \(command.getCommandID()) \(command.getCommandCode())" )
            }
        }
    }
    
    private class func processNewWebView( command: Command ) {
        checkNewWebView( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkNewWebView( command: Command, onSuccess:((Int)->()), onFail:((String)->()) ) {
        let parameter = (command.getParameter() as AnyObject).value(forKeyPath: "html_file")
        var htmlFile:HTMLFile?
        switch( parameter ) {
            case is HTMLFile:
                htmlFile = parameter as? HTMLFile
                break
            case is NSObject:
                htmlFile = HTMLFile( htmlFile: parameter as! NSDictionary )
                break
            default:
                break;
        }
        if htmlFile != nil {
            let wkmanager = WebViewManager( htmlFile: htmlFile! )
            if let properties = (command.getParameter() as AnyObject).value(forKeyPath: "property") as? NSDictionary {
                wkmanager.getWebview().setProperty(property: properties)
            }
            onSuccess( wkmanager.getID() )
        } else {
            onFail( "Please set HTML File" )
        }
    }
    
    private class func processLoadWebView( command: Command ) {
        checkLoadWebView( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkLoadWebView( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        if let wkmanager =  CommandProcessor.getWebViewManager(command: command) {
            wkmanager.load(onSuccess: {
                onSuccess( true )
            }, onFail: { (message) in
                onFail( message )
            })
        }
    }
    
    private class func processAnimateWebView( command: Command ) {
        checkAnimateWebView( command: command, onSuccess: { result in
            command.resolve( value: result )
        })
    }
    
    private class func checkAnimateWebView( command: Command, onSuccess:@escaping((Bool)->()) ) {
        if let wkmanager =  CommandProcessor.getWebViewManager(command: command) {
            let webview = wkmanager.getWebview()
            webview.setProperty(
                property: (command.getParameter() as AnyObject).value(forKeyPath: "property") as! NSDictionary,
                animation: (command.getParameter() as AnyObject).value(forKeyPath: "animation") as? NSDictionary,
                onSuccess: { (finished) in
                    onSuccess( finished )
            })
        }
    }
    
    private class func checkWebViewEvent( command: Command) {
        let _ = CommandProcessor.getWebViewManager(command: command)
    }
    
    private class func checkDownloadEvent( command: Command) {
        let _ = CommandProcessor.getDownloadFile(command: command)
    }
    
    public class func processWebViewOnload( wkmanager: WebViewManager ) {
        getCommand(commandCode: CommandCode.WEB_VIEW_ONLOAD) { (command) in
            if command.getTargetWebViewID() == wkmanager.getID() {
                command.resolve(value: true)
            }
        }
    }
    
    public class func processWebViewOnLoaded( wkmanager: WebViewManager ) {
        getCommand(commandCode: CommandCode.WEB_VIEW_ONLOADED) { (command) in
            if command.getTargetWebViewID() == wkmanager.getID() {
                command.resolve(value: true)
            }
        }
    }
    
    public class func processWebViewOnLoading( wkmanager: WebViewManager, progress: Double ) {
        getCommand(commandCode: CommandCode.WEB_VIEW_ONLOADING) { (command) in
            if command.getTargetWebViewID() == wkmanager.getID() {
                command.update(value:progress)
                if( progress >= 100.0 ) {
                    command.resolve(value: true)
                }
            }
        }
    }
    
    private class func processCloseWebView( command: Command ) {
        checkCloseWebView( command: command, onSuccess: { result in
            command.resolve( value: result )
        })
    }
    private class func checkCloseWebView( command: Command, onSuccess:@escaping ((Bool)->()) ) {
        if let wkmanager =  CommandProcessor.getWebViewManager(command: command) {
            wkmanager.close(onSuccess: {
                onSuccess( true )
            })
        }
    }
    
    private class func checkMediaPicker( command: Command ) {
        var isDuplicated = false
        getCommand(commandCode: CommandCode.MEDIA_PICKER) { (cmd) in
            if cmd !== command {
                isDuplicated = true
            }
        }
        if !isDuplicated {
            if let type = (command.getParameter() as AnyObject).value(forKeyPath: "from") as? String {
                if let pickerType = PickerType(rawValue: type) {
                    if !Photos.getMediaPickerController(view: Shared.shared.ViewController, type: pickerType) {
                        command.reject( errorMessage: "[ERROR] Photos.app is not available" )
                    }
                }
            }
        } else {
            command.reject( errorMessage: "[ERROR] The process is being used by another command" )
        }
    }
    public class func processMediaPicker( media:[String : Any]?=nil ) {
        CommandProcessor.getCommand(commandCode: CommandCode.MEDIA_PICKER) { (command) in
            if media != nil {
                if let type = (command.getParameter() as AnyObject).value(forKeyPath: "from") as? String {
                    if let pickerType = PickerType(rawValue: type) {
                        switch pickerType {
                        case PickerType.PHOTO_LIBRARY:
                            do {
                                if let imageURL = media![UIImagePickerControllerReferenceURL] as? URL {
                                    let imageFile = try ImageFile(assetURL: imageURL)
                                    command.resolve(value: imageFile.toDictionary(), raw: imageFile)
                                }
                            } catch let error as NSError {
                                command.reject(errorMessage: error.localizedDescription)
                            }
                            break
                        case PickerType.CAMERA:
                            let exifData = NSMutableDictionary(dictionary: media![UIImagePickerControllerMediaMetadata] as! NSDictionary )
                            if let takenImage = media![UIImagePickerControllerOriginalImage] as? UIImage {
                                do {
                                    let imageFile = try ImageFile( uiimage:takenImage, exif:exifData, savePath:"CACHE" )
                                    command.resolve(value: imageFile.toDictionary(), raw: imageFile)
                                } catch let error as NSError {
                                    command.reject( errorMessage: error.localizedDescription )
                                }
                                command.resolve(value: true)
                            } else {
                                command.reject( errorMessage: "Cannot obtain photo" )
                            }
                            break
                        case PickerType.VIDEO_LIBRARY:
                            if let videoURL = media![UIImagePickerControllerReferenceURL] as? URL {
                                command.resolve(value: true)
                                print( videoURL )
                            }
                            break
                        case PickerType.CAMCORDER:
                            if let videoURL = media![UIImagePickerControllerMediaURL] as? URL {
                                command.resolve(value: true)
                                print( videoURL )
                            }
                            break
                        }
                    }
                }
            } else {
                command.reject(errorMessage: "User cancelled operation")
            }
            
        }
    }
    
    
    
    
    private class func checkTakePhoto( command: Command ) {
        var isDuplicated = false
        getCommand(commandCode: CommandCode.TAKE_PHOTO) { (cmd) in
            if cmd !== command {
                isDuplicated = true
            }
        }
        if !isDuplicated {
            if let type = (command.getParameter() as AnyObject).value(forKeyPath: "from") as? String {
                if let pickerType = PickerType(rawValue: type) {
                    if !Photos.getMediaPickerController(view: Shared.shared.ViewController, type: pickerType) {
                        command.reject( errorMessage: "[ERROR] Photos.app is not available" )
                    }
                }
            }
        } else {
            command.reject( errorMessage: "[ERROR] The process is being used by another command" )
        }
    }
    public class func processTakePhoto( imageURL:URL?=nil ) {
        CommandProcessor.getCommand(commandCode: CommandCode.TAKE_PHOTO) { (command) in
            if imageURL != nil {
                do {
                    let imageFile = try ImageFile(assetURL: imageURL!)
                    command.resolve(value: imageFile.toDictionary(), raw: imageFile)
                } catch let error as NSError {
                    command.reject(errorMessage: error.localizedDescription)
                }
            } else {
                command.reject(errorMessage: "User cancelled operation")
            }
        }
    }
    
    private class func checkTakeVideo( command: Command ) {
        var isDuplicated = false
        getCommand(commandCode: CommandCode.TAKE_VIDEO) { (cmd) in
            if cmd !== command {
                isDuplicated = true
            }
        }
        if !isDuplicated {
            if let type = (command.getParameter() as AnyObject).value(forKeyPath: "from") as? String {
                if let pickerType = PickerType(rawValue: type) {
                    if !Photos.getMediaPickerController(view: Shared.shared.ViewController, type: pickerType) {
                        command.reject( errorMessage: "[ERROR] Photos.app is not available" )
                    }
                }
            }
        } else {
            command.reject( errorMessage: "[ERROR] The process is being used by another command" )
        }
    }
    public class func processTakeVideo( imageURL:URL?=nil ) {
        CommandProcessor.getCommand(commandCode: CommandCode.TAKE_VIDEO) { (command) in
            if imageURL != nil {
                do {
                    let imageFile = try ImageFile(assetURL: imageURL!)
                    command.resolve(value: imageFile.toDictionary(), raw: imageFile)
                } catch let error as NSError {
                    command.reject(errorMessage: error.localizedDescription)
                }
            } else {
                command.reject(errorMessage: "User cancelled operation")
            }
        }
    }
    
//    private class func processGetBase64Image( command: Command ) {
//        checkGetBase64Image( command: command, onSuccess: { result in
//            command.resolve( value: result )
//        }, onFail: { errorMessage in
//            command.reject( errorMessage: errorMessage )
//        })
//    }
//    private class func checkGetBase64Image( command:Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
//        let parameter = command.getParameter()
//        var imageFile:ImageFile?
//        switch( parameter ) {
//        case is ImageFile:
//            imageFile = parameter as? ImageFile
//            break
//        case is NSDictionary:
//            imageFile = ImageFile( imageFile: parameter as! NSDictionary )
//            break
//        default:
//            break;
//        }
//        if imageFile != nil {
//            imageFile!.getBase64Value(onSuccess: { (base64) in
//                command.resolve(value: base64)
//            }, onFail: { (error) in
//                command.reject( errorMessage: error )
//            })
//        } else {
//            command.reject( errorMessage: "Failed to get Image" )
//        }
//    }

    
    private class func processGetHTMLFile( command: Command ) {
        checkGetHTMLFile( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetHTMLFile( command:Command, onSuccess:@escaping ((String, HTMLFile)->()), onFail:@escaping ((String)->()) ) {
        do {
            let htmlFile = try HTMLFile( file: command.getParameter() as! NSDictionary)
            if let filePath = htmlFile.getFilePath() {
				onSuccess(filePath.absoluteString, htmlFile)
            } else {
                onFail( "File is not available" )
            }
        } catch let error as NSError {
            onFail( error.localizedDescription )
        }
    }

	private class func processDownloadFile( command: Command ) {
		CommandProcessor.checkDownloadFile( command: command, onSuccess: { result in
			command.resolve( value: result )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func checkDownloadFile( command:Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        if let downloadFile = getDownloadFile( command: command ) {
            downloadFile.download(onSuccess: { (result) in
                onSuccess(result)
            }, onFail: { (error) in
                onFail(error)
            })
        }
	}

    private class func processNewDownloadFile( command: Command ) {
        checkNewDownloadFile( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkNewDownloadFile( command: Command, onSuccess:@escaping ((NSDictionary, DownloadFile)->()), onFail:@escaping ((String)->()) ) {
        do {
            let downloadFile = try DownloadFile( file: command.getParameter() as! NSDictionary )
            onSuccess(downloadFile.toDictionary(), downloadFile)
        } catch let error as NSError {
            print( error )
            onFail( error.localizedDescription )
        }
    }

    private class func processGetFile( command: Command ) {
        checkGetFile( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetFile( command: Command, onSuccess:@escaping ((String, File)->()), onFail:@escaping ((String)->()) ) {
        do {
            let file = try File( file: command.getParameter() as! NSObject )
            if let filePath = file.getFilePath() {
                onSuccess(filePath.absoluteString, file)
            } else {
                onFail( "File is not available" )
            }
        } catch let error as NSError {
            onFail( error.localizedDescription )
        }
    }
    
    private class func processGetVideoFile( command: Command ) {
        checkGetVideoFile( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetVideoFile( command:Command, onSuccess:@escaping ((String, VideoFile)->()), onFail:@escaping ((String)->()) ) {
        do {
            let videoFile = try VideoFile( file: command.getParameter() as! NSDictionary)
            if let filePath = videoFile.getFilePath() {
                onSuccess(filePath.absoluteString, videoFile)
            } else {
                onFail( "File is not available" )
            }
        } catch let error as NSError {
            onFail( error.localizedDescription )
        }
    }
    
    private class func processGetExifImage( command: Command ) {
        checkGetExifImage( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetExifImage( command:Command, onSuccess:@escaping ((NSDictionary)->()), onFail:@escaping ((String)->()) ) {
        let parameter = command.getParameter()
        var imageFile:ImageFile?
        switch( parameter ) {
        case is ImageFile:
            imageFile = parameter as? ImageFile
            break
        case is NSDictionary:
            imageFile = ImageFile( imageFile: parameter as! NSDictionary )
            break
        default:
            break;
        }
        if imageFile != nil {
            imageFile!.getEXIFInfo(onSuccess: { (exif) in
                onSuccess( exif )
            }, onFail: { (error) in
                onFail( error )
            })
        } else {
            onFail( "Failed to get Image" )
        }
    }
    
    
    private class func processGetBase64Binary( command: Command ) {
        checkGetBase64Binary( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetBase64Binary( command:Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        let parameter = command.getParameter()
        var imageFile:ImageFile?
        switch( parameter ) {
        case is ImageFile:
            imageFile = parameter as? ImageFile
            break
        case is NSDictionary:
            imageFile = ImageFile( imageFile: parameter as! NSDictionary )
            break
        default:
            break;
        }
        if imageFile != nil {
            imageFile!.getBase64Value(onSuccess: { (base64) in
                command.resolve(value: base64)
            }, onFail: { (error) in
                command.reject( errorMessage: error )
            })
        } else {
            command.reject( errorMessage: "Failed to get Image" )
        }
    }
    
    private class func processGetBase64Resized( command: Command ) {
        checkGetBase64Resized( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetBase64Resized( command:Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        let imgParam = (command.getParameter() as? NSObject)?.value(forKeyPath: "image_file")
        let option:NSObject = (command.getParameter() as? NSObject)?.value(forKeyPath: "option") as! NSObject
        var imageFile:ImageFile?
        switch( imgParam ) {
        case is ImageFile:
            imageFile = imgParam as? ImageFile
            break
        case is NSDictionary:
            imageFile = ImageFile( imageFile: imgParam as! NSDictionary )
            break
        default:
            break;
        }
        if imageFile != nil {
            imageFile!.getBase64Resized( option:option,  onSuccess: { (base64) in
                command.resolve(value: base64)
            }, onFail: { (error) in
                command.reject( errorMessage: error )
            })
        } else {
            command.reject( errorMessage: "Failed to get Image" )
        }
    }
    
    
    private class func processGetVideoBase64Binary( command: Command ) {
        checkGetVideoBase64Binary( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetVideoBase64Binary( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        let parameter = command.getParameter()
        var videoFile:VideoFile?
        switch( parameter ) {
        case is VideoFile:
            videoFile = parameter as? VideoFile
            break
        case is NSObject:
            videoFile = VideoFile( videoFile: parameter as! NSDictionary )
            break
        default:
            break;
        }
        if videoFile != nil {
            videoFile!.getBase64Value(onSplit: { (chunk) in
                command.update(value: chunk.base64EncodedString())
            }, onSuccess: { (result) in
                onSuccess(result)
            }, onFail: { (error) in
                onFail(error)
            })
        } else {
            onFail( "Video does not exist" )
        }
    }
    
    
    
    private class func processGetVideo( command: Command ) {
        checkGetVideo( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetVideo( command: Command, onSuccess:@escaping ((String, VideoFile)->()), onFail:@escaping ((String)->()) ) {
        do {
            let videoFile = try VideoFile( file: command.getParameter() as! NSDictionary)
            if let filePath = videoFile.getFilePath() {
                onSuccess(filePath.absoluteString, videoFile)
            } else {
                onFail( "File is not available" )
            }
        } catch let error as NSError {
            onFail( error.localizedDescription )
        }
        
        
    }
    
    
    private class func processNewAVPlayer( command: Command ) {
        checkNewAVPlayer( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkNewAVPlayer( command: Command, onSuccess:@escaping ((Int)->()), onFail:@escaping ((String)->()) ) {
        let parameter = (command.getParameter() as AnyObject).value(forKeyPath: "video_file")
        var videoFile:VideoFile?
        switch( parameter ) {
        case is VideoFile:
            videoFile = parameter as? VideoFile
            break
        case is NSDictionary:
            videoFile = VideoFile( videoFile: parameter as! NSDictionary )
            break
        default:
            break;
        }
        if videoFile != nil {
            let avplayermanager = AVPlayerManager( videoFile: videoFile! )
            if let properties = (command.getParameter() as AnyObject).value(forKeyPath: "property") as? NSDictionary {
                avplayermanager.setProperty(property: properties)
            }
            onSuccess( avplayermanager.getID() )
        } else {
            onFail( "Please set HTML File" )
        }
    }
    
    private class func processAppendAVPlayer( command: Command ) {
        checkAppendAVPlayer( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkAppendAVPlayer( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        if let wkmanager =  CommandProcessor.getWebViewManager(command: command) {
            if let avmanager = CommandProcessor.getAVPlayerManager(command: command) {
                let isFixed = (command.getParameter() as AnyObject).value(forKeyPath: "isFixed") as? Bool
                wkmanager.appendAVPlayer(avmanager: avmanager, isFixed:isFixed )
                onSuccess( true )
                return
            }
        }
    }
    
    private class func processAVPlayerPlay( command: Command ) {
        checkAVPlayerPlay( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkAVPlayerPlay( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        if let avmanager = CommandProcessor.getAVPlayerManager(command: command) {
            if let player = avmanager.getAVPlayer().player {
                player.play()
                onSuccess( true )
                return
            }
        }
    }
    
    private class func processAVPlayerPause( command: Command ) {
        checkAVPlayerPause( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkAVPlayerPause( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        if let avmanager = CommandProcessor.getAVPlayerManager(command: command) {
            if let player = avmanager.getAVPlayer().player {
                player.pause()
                onSuccess( true )
                return
            }
        }
    }
    
    private class func processAVPlayerSeek( command: Command ) {
        checkAVPlayerSeek( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkAVPlayerSeek( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        if let avmanager = CommandProcessor.getAVPlayerManager(command: command) {
            if let seconds = (command.getParameter() as AnyObject).value(forKeyPath: "seconds") as? Double {
                avmanager.seek(seconds: seconds, onSuccess: { (result) in
                    onSuccess( result )
                })
                return
            }
            onFail( "please set seconds" )
        }
    }
    
    
    //PLEASE NOTE THAT THIS PROCCESS WONT RUN ON ITS OWN WITHOUT USER INTERACTION
    private class func proccessChangeIcon( command: Command ) {
        checkChangeIcon( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkChangeIcon( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        if let name = (command.getParameter() as AnyObject).value(forKeyPath: "name") as? String {
            var iconName:String?
            if name != "default" {
                iconName = name
            }
            Shared.shared.UIApplication.setAlternateIconName(iconName) { (error) in
                if error != nil {
                    onFail( error!.localizedDescription )
                    return
                } else {
                    onFail( "unknown error happend" )
                    return
                }
            }
            onSuccess( true )
        } else {
            onFail( "please set name parameter" )
        }
    }
    
    public class func processOnDownload( downloadFile: DownloadFile ) {
        getCommand(commandCode: CommandCode.ONDOWNLOAD) { (command) in
			if let innerDownloadFile = CommandProcessor.getDownloadFile(command: command) {
				if innerDownloadFile.getID() == downloadFile.getID() {
					command.resolve(value: true)
				}
			}
        }
    }
    public class func processOnDownloaded( downloadFile: DownloadFile, downloadedFilePath:URL ) {
        getCommand(commandCode: CommandCode.ONDOWNLOADED) { (command) in
            if let innerDownloadFile = CommandProcessor.getDownloadFile(command: command) {
				if innerDownloadFile.getID() == downloadFile.getID() {
					command.resolve(value: downloadedFilePath.path)
				}
			}
        }
    }
    public class func processOnDownloading( downloadFile: DownloadFile, progress: Double ) {
        getCommand(commandCode: CommandCode.ONDOWNLOADING) { (command) in
            if let innerDownloadFile = CommandProcessor.getDownloadFile(command: command) {
				if innerDownloadFile.getID() == downloadFile.getID() {
					command.update(value:progress)
					if( progress >= 100.0 ) {
						command.resolve(value: true)
					}
				}
            }
        }
    }

    private class func processMoveFile( command: Command ) {
        checkMoveFile( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkMoveFile( command: Command, onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ) {
        let parameter = (command.getParameter() as AnyObject).value(forKeyPath: "file")
        var file:File?
        switch( parameter ) {
        case is File:
            file = parameter as? File
            break
        case is NSDictionary:
            do {
                file = try File( file: parameter as! NSDictionary )
            } catch let error as NSError {
                onFail( error.localizedDescription )
                return
            }
            break
        default:
            break;
        }
        if file != nil {
            let toPath = (command.getParameter() as AnyObject).value(forKeyPath: "to") as? String
            let isOverwrite = (command.getParameter() as AnyObject).value(forKeyPath: "isOverwrite") as? Bool
            let _ = file!.move(relative: toPath, isOverwrite: isOverwrite, onSuccess: { (newPath) in
                onSuccess( newPath.path )
            }, onFail: { (error) in
                onFail( error )
            })
        } else {
            onFail( "Failed to initialize File" )
        }
    }
    
    private class func processRenameFile( command: Command ) {
        checkRenameFile( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkRenameFile( command: Command, onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ) {
        let parameter = (command.getParameter() as AnyObject).value(forKeyPath: "file")
        var file:File?
        switch( parameter ) {
        case is File:
            file = parameter as? File
            break
        case is NSDictionary:
            do {
                file = try File( file: parameter as! NSDictionary )
            } catch let error as NSError {
                onFail( error.localizedDescription )
                return
            }
            break
        default:
            break;
        }
        if file != nil {
            if let fileName = (command.getParameter() as AnyObject).value(forKeyPath: "filename") as? String {
                let _ = file!.rename(fileName: fileName, onSuccess: { (newPath) in
                    onSuccess( newPath.path )
                }, onFail: { (error) in
                    onFail( error )
                })
            } else {
                onFail( "filename parameter not existent" )
            }
        } else {
            onFail( "Failed to initialize File" )
        }
    }
    
    private class func processCopyFile( command: Command ) {
        checkCopyFile( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkCopyFile( command: Command, onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ) {
        let parameter = (command.getParameter() as AnyObject).value(forKeyPath: "file")
        var file:File?
        switch( parameter ) {
        case is File:
            file = parameter as? File
            break
        case is NSDictionary:
            do {
                file = try File( file: parameter as! NSDictionary )
            } catch let error as NSError {
                onFail( error.localizedDescription )
                return
            }
            break
        default:
            break;
        }
        if file != nil {
            if let relative = (command.getParameter() as AnyObject).value(forKeyPath: "relative") as? String {
                let _ = file!.copy(relative: relative, onSuccess: { (newPath) in
                    onSuccess( newPath.path )
                }, onFail: { (error) in
                    onFail( error )
                })
            } else {
                onFail( "filename parameter not existent" )
            }
        } else {
            onFail( "Failed to initialize File" )
        }
    }
    
    private class func processDeleteFile( command: Command ) {
        checkDeleteFile( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkDeleteFile( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {
        let parameter = (command.getParameter() as AnyObject).value(forKeyPath: "file")
        var file:File?
        switch( parameter ) {
        case is File:
            file = parameter as? File
            break
        case is NSDictionary:
            do {
                file = try File( file: parameter as! NSDictionary )
            } catch let error as NSError {
                onFail( error.localizedDescription )
                return
            }
            break
        default:
            break;
        }
        if file != nil {
            let _ = file!.delete( onSuccess: { result in
                onSuccess( result )
            }, onFail: { (error) in
                onFail( error )
            })
        } else {
            onFail( "Failed to initialize File" )
        }
    }
}



















