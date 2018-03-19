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


class CommandProcessor {
    
    private static var QUEUE:[Command] = [Command]();
    
    private class func _queue( command: Command ) {
        CommandProcessor.QUEUE.append( command )
        
        switch command.getCommandCode() {
        case .NEW_WEB_VIEW:
            processNewWebView( command: command )
            break
        case .LOAD_WEB_VIEW:
            processLoadWebView( command: command )
            break
        case .ANIMATE_WEB_VIEW:
            processAnimateWebView( command: command )
            break
        case .WEB_VIEW_ONLOAD,
             .WEB_VIEW_ONLOADED,
             .WEB_VIEW_ONLOADING:
            checkWebViewEvent( command: command )
            break
        case .CLOSE_WEB_VIEW:
            processCloseWebView( command: command )
            break
        case .GET_FILE:
            processGetFile( command: command )
            break
        case .GET_HTML_FILE:
            processGetHTMLFile( command: command )
            break
        case .GET_IMAGE_FILE:
            processGetImageFile( command: command )
            break
        case .GET_BASE64_BINARY:
            processGetBase64Binary( command: command )
            break
        case .GET_BASE64_RESIZED:
            processGetBase64Resized( command: command )
            break
        case .MEDIA_PICKER:
            checkMediaPicker( command: command )
            break
        case .CHANGE_ICON:
            proccessChangeIcon(command: command)
            break
        case .MOVE_FILE:
            processMoveFile( command: command )
            break
        case .RENAME_FILE:
            processRenameFile( command: command )
            break
        case .SHAKE_BEGIN:
            //checkShakeBegin(command: command)
            break
        case .SHAKE_END:
            //checkShakeEnd(command: command)
            break
        case .COPY_FILE:
            processCopyFile( command: command )
            break
        case .DELETE_FILE:
            processDeleteFile( command: command )
            break
        case .REMOVE_EVENT_LISTENER:
            checkRemoveEventListener(command: command)
            break
        case .OPEN_WITH_SAFARI:
            checkOpenWithSafari( command: command )
            break
        case .USER_SETTINGS:
            checkUserSettings( command: command )
            break
        case .USER_SETTINGS_STARTUP_HTML:
            checkUserSettingsStartupHtml( command: command )
            break
        case .USER_SETTINGS_DELETE:
            checkUserSettingsDelete( command: command )
            break
        case .USER_SETTINGS_SET:
            checkUserSettingsSet( command: command )
            break
        case .USER_SETTINGS_GET:
            checkUserSettingsGet( command: command )
            break
        case .SCREEN_EDGE_SWIPED:
            checkScreenEdgeSwiped( command: command )
            break
        case .WEB_VIEW_RECIEVEMESSAGE:
            checkWebViewRecieveMessage( command: command )
            break
        case .WEB_VIEW_POSTMESSAGE:
            checkWebViewPostMessage( command: command )
            break
        case .USER_SETTINGS_LUNASETTINGS_HTML:
            checkUserSettingsLunaSettingsHtml( command: command )
            break
        case .USER_NOTIFICATION:
            checkUserNotification( command: command )
            break
        case .USER_NOTIFICATION_SHOWMSG:
            checkUserNotificationShowMessage( command: command )
            break
        case .HTTP_POST:
            checkHttpPost( command: command )
            break
		case .SYSTEM_SETTINGS:
			checkSystemSettings( command: command )
			break
		case .SYSTEM_SETTINGS_SET:
			checkSystemSettingsSet( command: command )
			break
        case .LOGACCESS:
            checkLogAccess( command: command )
            break
        case .SF_SERVICESOS_INIT:
            checkSFServiceSOSInit( command: command )
            break
        case .SF_SERVICESOS_START:
            checkSFServiceSOSStart( command: command )
            break
        case .SF_SERVICESOS_STATECHANGE,
             .SF_SERVICESOS_DIDSTOP,
             .SF_SERVICESOS_DIDCONNECT:
            break
        case .SF_SERVICESOS_STOP:
            checkSFServiceSOSStop( command: command )
            break
        case .SF_SERVICELIVEA_INIT:
            checkSFServiceLiveAgentInit( command: command )
            break
        case .SF_SERVICELIVEA_START:
            checkSFServiceLiveAgentStart( command: command )
            break
        case .SF_SERVICELIVEA_ADDPREOBJ:
            checkSFServiceLiveAgentAddPrechatObject( command: command )
            break
        case .SF_SERVICELIVEA_CLEARPREOBJ:
            checkSFServiceLiveAgentClearPrechatObject( command: command )
            break
        case .SF_SERVICELIVEA_STATECHANGE,
             .SF_SERVICELIVEA_DIDEND:
            break
        case .SF_SERVICELIVEA_CHECKAVAIL:
            checkSFServiceLiveAgentCheckAvailability( command: command )
            break
        case .HAPTIC_INIT:
            processHapticFeedbackInit(command: command)
            break
        case .HAPTIC_FEEDBACK:
            processHapticFeedbackExecute(command: command)
            break
        case .EINSTEIN_VISION_INIT:
            proccessEinsteinAuth(command: command)
            break
        case .EINSTEIN_VISION_PREDICT:
            proccessEinsteinVisionPredict(command: command)
            break
        case .BETA_SHOWEINSTEIN_AR:
            processShowEinsteinARBeta(command: command)
            break
        case .OPEN_APP_SETTINGS:
            processOpenAppSettings(command: command)
            break
        case .EINSTEIN_VISION_DATASETS:
            proccessEinsteinVisionDatasets(command: command)
            break
        case .EINSTEIN_VISION_MODELS:
            proccessEinsteinVisionModels(command: command)
            break
        default:
            print( "[ERROR] Invalid Command Code: \(command.getCommandCode())" )
            command.reject(errorMessage: "Invalid Command Code: \(command.getCommandCode())")
            return
        }
    }
    
    public class func queue( command: Command ) {
        var dispatchQos = DispatchQoS.default
        switch command.getPriority() {
        case .CRITICAL:
            DispatchQueue.global(qos: .userInteractive).async(execute: {
                DispatchQueue.main.async {
                    _queue( command: command )
                }
            })
            return
        case .HIGH:
            dispatchQos = DispatchQoS.userInteractive
            break
        case .NORMAL:
            dispatchQos = DispatchQoS.userInitiated
            break
        case .LOW:
            dispatchQos = DispatchQoS.utility
            break
        case .BACKGROUND:
            dispatchQos = DispatchQoS.background
            break
        }
        DispatchQueue.global(qos: dispatchQos.qosClass).async(execute: {
            _queue( command: command )
        })
    }
    
    public class func getWebViewManager( command: Command ) -> WebViewManager? {
        if let wkmanager = WebViewManager.getManager(webview_id: command.getTargetWebViewID()) {
            return wkmanager
        } else {
            command.reject( errorMessage: "[ERROR] No webview with ID of \(command.getTargetWebViewID()) found." )
        }
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
    public class func getCommand( commandID:Int, ifFound:((Command)->()) ) {
        for (_, command) in CommandProcessor.getQueue().enumerated() {
            if command.getCommandID() == commandID {
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
        var htmlFile:HtmlFile?
        switch( parameter ) {
            case is HtmlFile:
                htmlFile = parameter as? HtmlFile
                break
            case is NSObject:
                htmlFile = HtmlFile( htmlFile: parameter as! NSDictionary )
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
    
    
    public class func processWebViewOnload( wkmanager: WebViewManager ) {
        getCommand(commandCode: CommandCode.WEB_VIEW_ONLOAD) { (command) in
            if let webviewId = (command.getParameter() as AnyObject).value(forKeyPath: "webview_id") as? Int {
                if webviewId == wkmanager.getID() {
                    command.update(value: true)
                }
            }
        }
    }
    
    public class func processWebViewOnLoaded( wkmanager: WebViewManager, isSuccess:Bool, errorMessage: String?=nil ) {
        getCommand(commandCode: CommandCode.WEB_VIEW_ONLOADED) { (command) in
            if let webviewId = (command.getParameter() as AnyObject).value(forKeyPath: "webview_id") as? Int {
                if webviewId == wkmanager.getID() {
                    let param = NSMutableDictionary()
                    param.setValue( isSuccess, forKey: "success")
                    if isSuccess {
                        command.update(value: param)
                    } else {
                        param.setValue( errorMessage, forKey: "message")
                        command.update(value: param)
                    }
                }
            }
        }
    }
    
    public class func processWebViewOnLoading( wkmanager: WebViewManager, progress: Double ) {
        getCommand(commandCode: CommandCode.WEB_VIEW_ONLOADING) { (command) in
            if let webviewId = (command.getParameter() as AnyObject).value(forKeyPath: "webview_id") as? Int {
                if webviewId == wkmanager.getID() {
                    command.update(value:progress)
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
                    let getPickerController = { (command: Command) -> () in
                        if !Photos.getMediaPickerController(view: Shared.shared.ViewController, type: pickerType) {
                            command.reject( errorMessage: "[ERROR] Photos.app is not available" )
                        }
                    }
                    let requestAuthorization = { (command: Command, isRequestAuth: Bool) -> () in
                        if( isRequestAuth ) {
                            PHPhotoLibrary.requestAuthorization({(newStatus) in
                                if newStatus ==  PHAuthorizationStatus.authorized {
                                    getPickerController( command )
                                } else {
                                    command.reject(errorMessage: "Not authorized to access Photos app")
                                }
                            })
                        } else {
                            getPickerController( command )
                        }
                    }
                    if pickerType == .PHOTO_LIBRARY {
                        requestAuthorization( command, true)
                    } else {
                        requestAuthorization( command, false)
                    }
                }
            }
        } else {
            command.reject( errorMessage: "[ERROR] The process is being used by another command" )
        }
    }
    public class func processMediaPicker( media:[String : Any]?=nil, isAllowed:Bool?=true ) {
        getCommand(commandCode: CommandCode.MEDIA_PICKER) { (command) in
            if media != nil {
                if let type = (command.getParameter() as AnyObject).value(forKeyPath: "from") as? String {
                    if let pickerType = PickerType(rawValue: type) {
                        switch pickerType {
                        case PickerType.PHOTO_LIBRARY:
                            if( isAllowed == true ) {
                                do {
                                    if let imageURL = media![UIImagePickerControllerImageURL] as? URL, let phasset = media![UIImagePickerControllerPHAsset] as? PHAsset {
                                        let imageFile = try ImageFile( fileId:File.generateID(), localIdentifier:phasset.localIdentifier, assetURL: imageURL)
                                        command.resolve(value: imageFile.toDictionary(), raw: imageFile)
                                    }
                                } catch let error as NSError {
                                    command.reject(errorMessage: error.localizedDescription)
                                }
                            } else {
                                command.reject(errorMessage: "Not authorized to access Photos App")
                            }
                            break
                        case PickerType.CAMERA:
                            let exifData = NSMutableDictionary(dictionary: media![UIImagePickerControllerMediaMetadata] as! NSDictionary )
                            if let takenImage = media![UIImagePickerControllerOriginalImage] as? UIImage {
                                do {
                                    let imageFile = try ImageFile( fileId:File.generateID(), uiimage:takenImage, exif:exifData, savePath:"CACHE" )
                                    command.resolve(value: imageFile.toDictionary(), raw: imageFile)
                                } catch let error as NSError {
                                    command.reject( errorMessage: error.localizedDescription )
                                }
                                command.resolve(value: true)
                            } else {
                                command.reject( errorMessage: "Cannot obtain photo" )
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
    
    private class func processGetImageFile( command: Command ) {
        checkGetImageFile( command: command, onSuccess: { result, raw in
			command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetImageFile( command:Command, onSuccess:@escaping ((NSDictionary, ImageFile)->()), onFail:@escaping ((String)->()) ) {
        let parameter = command.getParameter()
        var imageFile:ImageFile?
        switch( parameter ) {
        case is ImageFile:
            imageFile = parameter as? ImageFile
            break
        case is NSDictionary:
			do {
				imageFile = try ImageFile( file: parameter as! NSDictionary )
			} catch  _ as NSError {}
            break
        default:
            break;
        }
        if imageFile != nil {
			onSuccess(imageFile!.toDictionary(), imageFile!)
        } else {
            command.reject( errorMessage: "Failed to get Image" )
        }
    }

    
    private class func processGetHTMLFile( command: Command ) {
        checkGetHTMLFile( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkGetHTMLFile( command:Command, onSuccess:@escaping ((NSDictionary, HtmlFile)->()), onFail:@escaping ((String)->()) ) {
        do {
            let htmlFile = try HtmlFile( file: command.getParameter() as! NSDictionary )
            onSuccess(htmlFile.toDictionary(), htmlFile)
        } catch let error as NSError {
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
    private class func checkGetFile( command: Command, onSuccess:@escaping ((NSDictionary, File)->()), onFail:@escaping ((String)->()) ) {
        do {
            let file = try File( file: command.getParameter() as! NSObject )
            onSuccess(file.toDictionary(), file)
        } catch let error as NSError {
            onFail( error.localizedDescription )
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
		var file:File?
		switch( parameter ) {
		case is File:
			file = parameter as? File
			break
		case is NSDictionary:
            if let object_type = (parameter as! NSDictionary).value(forKeyPath: "object_type") as? String {
                switch( object_type ) {
                case "ImageFile":
                    file = ImageFile( imageFile: parameter as! NSDictionary )
                    break
                default:
                    file = File( filedict: parameter as! NSDictionary )
                    break
                }
            }
			break
		default:
			break;
		}
		if file != nil {
			file!.getBase64Value(onSuccess: { (base64) in
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

    private class func proccessChangeIcon( command: Command ) {
        checkChangeIcon( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkChangeIcon( command: Command, onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->()) ) {

        if Shared.shared.UIApplication.supportsAlternateIcons {
            if let name = (command.getParameter() as AnyObject).value(forKeyPath: "name") as? String {
                var iconName:String?
                if name != "default" {
                    iconName = name
                }
                Shared.shared.UIApplication.setAlternateIconName(iconName) { (error) in
                    if error != nil {
                        onFail( error!.localizedDescription )
                    } else {
                        onSuccess( true )
                    }
                }
            } else {
                onFail( FileError.INVALID_PARAMETERS.localizedDescription )
            }
        } else {
            onFail("Device doesn't support alternate icons")
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
            if let to = (command.getParameter() as AnyObject).value(forKeyPath: "to") as? String {
                let _ = file!.copy(relative: to, onSuccess: { (newPath) in
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

    
    public class func processShakeBegin( ) {
        getCommand(commandCode: .SHAKE_BEGIN) { (command) in
            command.update(value: true)
        }
    }
    
    public class func processShakeEnd( ) {
        getCommand(commandCode: .SHAKE_END) { (command) in
            command.update(value: true)
        }
    }
    
    private class func checkRemoveEventListener( command: Command ) {
        processRemoveEventListener( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func processRemoveEventListener( command: Command, onSuccess: ((Int)->()), onFail: ((String)->()) ) {
        if let commandCodeVal = (command.getParameter() as! NSDictionary).value(forKey: "evt_command_code") as? Int {
            if let evtCommandCode = CommandCode(rawValue: commandCodeVal) {
                var count = 0
                if let commandID = (command.getParameter() as! NSDictionary).value(forKey: "event_id") as? Int {
                    getCommand(commandID: commandID) { (evtcommand) in
                        if evtcommand.getSourceWebViewID() == command.getSourceWebViewID() {
                            evtcommand.resolve(value: true, raw: true)
                            count+=1
                        }
                    }
                } else {
                    getCommand(commandCode: evtCommandCode) { (evtcommand) in
                        if evtcommand.getSourceWebViewID() == command.getSourceWebViewID() {
                            evtcommand.resolve(value: true, raw: true)
                            count+=1
                        }
                    }
                }
                
                if count > 0 {
                    onSuccess( count )
                } else {
                    onFail( "No Event Available" )
                }
            } else {
                onFail( "No Event Available" )
                return
            }
            
        }
    }


    private class func checkOpenWithSafari( command: Command ) {
        processOpenWithSafari( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processOpenWithSafari( command: Command, onSuccess: @escaping ((Bool)->()), onFail: @escaping ((String)->()) ) {
        let parameter = (command.getParameter() as AnyObject).value(forKeyPath: "file")
        var htmlFile:HtmlFile?
        switch( parameter ) {
        case is HtmlFile:
            htmlFile = parameter as? HtmlFile
            break
        case is NSObject:
            htmlFile = HtmlFile( htmlFile: parameter as! NSDictionary )
            break
        default:
            break;
        }
        if htmlFile != nil {
            htmlFile!.openWithSafari(onSuccess: onSuccess, onFail: onFail)
        } else {
            onFail( "Please set HTML File" )
        }
    }
    
    private class func checkUserSettings( command: Command ) {
        procesUserSettings( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func procesUserSettings( command: Command, onSuccess: ((NSDictionary)->()), onFail: ((String)->()) ){
        onSuccess( UserSettings.instance.getUserSettings() )
    }
    
    private class func checkUserSettingsStartupHtml( command: Command ) {
        processUserSettingsStartupHtml( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processUserSettingsStartupHtml( command: Command, onSuccess: ((NSDictionary, HtmlFile)->()), onFail: ((String)->()) ){
        if let htmlFile = UserSettings.instance.getStartupHtmlFile() {
            onSuccess( htmlFile.toDictionary(), htmlFile )
        } else {
            onFail(FileError.INEXISTENT.localizedDescription)
        }
    }
    
    
    private class func checkScreenEdgeSwiped( command: Command ) {
		var found = false
		var count = 0

		let touchesRequired = (command.getParameter() as AnyObject).value(forKeyPath: "touchesRequired") as? Int
		let direction = (command.getParameter() as AnyObject).value(forKeyPath: "direction") as? String


		getCommand(commandCode: .SCREEN_EDGE_SWIPED) { (cmd) in
			let cmdTouchesRequired = (cmd.getParameter() as AnyObject).value(forKeyPath: "touchesRequired") as? Int
			let cmdDirection = (cmd.getParameter() as AnyObject).value(forKeyPath: "direction") as? String
			if touchesRequired == cmdTouchesRequired && cmdDirection == direction {
				count += 1
				if count > 1 {
					found = true
				}
			}
		}

		if !found {
			let gestureRecognizer = UISwipeGestureRecognizer()
			gestureRecognizer.numberOfTouchesRequired = touchesRequired!
			switch touchesRequired! {
			case 2:
				gestureRecognizer.addTarget(Shared.shared.ViewController, action: #selector( Shared.shared.ViewController.screenEdgeSwipedTwoFingers(_:)))
				break
			case 3:
				gestureRecognizer.addTarget(Shared.shared.ViewController, action: #selector( Shared.shared.ViewController.screenEdgeSwipedThreeFingers(_:)))
				break
			default:
				gestureRecognizer.addTarget(Shared.shared.ViewController, action: #selector( Shared.shared.ViewController.screenEdgeSwipedOneFinger(_:)))
				break
			}

			switch direction!.lowercased() {
				case "left":
					gestureRecognizer.direction = .left
				break
				case "up":
					gestureRecognizer.direction = .up
				break
				case "down":
					gestureRecognizer.direction = .down
				break
				default:
					gestureRecognizer.direction = .right
				break
			}
			Shared.shared.ViewController.view.addGestureRecognizer(gestureRecognizer)
		}
    }

	public class func processSwipeGesture( swipeDirection: UISwipeGestureRecognizerDirection, touchesRequired:Int ) {
		getCommand(commandCode: .SCREEN_EDGE_SWIPED) { (command) in
			let ctouchesRequired = (command.getParameter() as AnyObject).value(forKeyPath: "touchesRequired") as? Int
			let direction = ((command.getParameter() as AnyObject).value(forKeyPath: "direction") as! String).lowercased()

			if( touchesRequired == ctouchesRequired ) {
				switch swipeDirection {
				case UISwipeGestureRecognizerDirection.left:
					if direction == "left" {
						command.update(value: true)
					}
					break
				case UISwipeGestureRecognizerDirection.up:
					if direction == "up" {
						command.update(value: true)
					}
					break
				case UISwipeGestureRecognizerDirection.down:
					if direction == "down" {
						command.update(value: true)
					}
					break
				default:
					if direction == "right" {
						command.update(value: true)
					}
					break
				}
			}
		}
	}

}



