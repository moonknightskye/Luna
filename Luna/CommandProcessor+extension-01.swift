//
//  CommandProcessor+extension-01.swift
//  Luna
//
//  Created by Mart Civil on 2017/05/25.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UserNotifications
import ServiceCore
import ServiceSOS
import CoreLocation

extension CommandProcessor {
    
    public class func processShowEinsteinARBeta( command: Command ) {
        let accountId = (command.getParameter() as AnyObject).value(forKeyPath: "accountId") as? String
        let privateKey = (command.getParameter() as AnyObject).value(forKeyPath: "privateKey") as? String
        let modelId = (command.getParameter() as AnyObject).value(forKeyPath: "modelId") as? String
        
        AR_BETA.instance.run(accountId: accountId, privateKey: privateKey, modelId: modelId)
    }
    
    public class func processOpenAppSettings( command: Command ) {
        let url = URL(string: "app-settings:root=General&path=com.salesforce.LunaEinsteinVision")!
        UIApplication.shared.open(url, options: [:], completionHandler: {(Bool)->() in
            command.resolve(value: true)
        })
    }
    
    public class func proccessEinsteinAuth(command: Command) {
        let accountId = (command.getParameter() as AnyObject).value(forKeyPath: "accountId") as? String
        let privateKey = (command.getParameter() as AnyObject).value(forKeyPath: "privateKey") as? String
        let isRequestNew = (command.getParameter() as AnyObject).value(forKeyPath: "isRequestNew") as? Bool ?? false
        EinsteinAuth.instance.getToken(accountId: accountId, privateKey: privateKey, isRequestNew:isRequestNew, onSuccess: { (access_token) in
            command.resolve(value: access_token)
        }) { (error) in
            command.reject(errorMessage: error)
        }
    }
    public class func proccessEinsteinVisionPredict(command: Command) {
        guard let token = (command.getParameter() as AnyObject).value(forKeyPath: "token") as? String else {
            command.reject(errorMessage: "no token")
            return
        }
        
        let modelId = (command.getParameter() as AnyObject).value(forKeyPath: "modelId") as? String
        let base64 = (command.getParameter() as AnyObject).value(forKeyPath: "base64") as? String
        let imgfile = (command.getParameter() as AnyObject).value(forKeyPath: "imageFile")

        var imageFile:ImageFile?
        switch( imgfile ) {
        case is ImageFile:
            imageFile = imgfile as? ImageFile
            break
        case is NSDictionary:
            do {
                imageFile = try ImageFile( file: imgfile as! NSDictionary )
            } catch  _ as NSError {}
            break
        default:
            imageFile = nil
            break;
        }
        
        let execute = { base64val in
            EinsteinVision.instance.predict(token: token, modelId: modelId, base64: base64val, onSuccess: { (result) in
                command.resolve(value: result)
            }, onFail: { (errorMessage) in
                command.reject(errorMessage: errorMessage)
            })
        }
        
        if let _ = base64 {
            execute( base64! )
        } else if let _ = imageFile {
            EinsteinVision.instance.preprocessImage(imageFile: imageFile!, onSuccess: { (base64) in
                execute( base64 )
            }, onError: { (errorMessage) in
                command.reject(errorMessage: errorMessage)
            })
        } else {
            command.reject(errorMessage: "no image file")
        }
    }
    public class func proccessEinsteinVisionDatasets(command: Command) {
        guard let token = (command.getParameter() as AnyObject).value(forKeyPath: "token") as? String else {
            command.reject(errorMessage: "no token")
            return
        }
        EinsteinVision.instance.datasets(token: token, onSuccess: { (value) in
            command.resolve(value: value)
        }) { (error) in
            command.reject(errorMessage: error)
        }
    }
    public class func proccessEinsteinVisionModels(command: Command) {
        guard let token = (command.getParameter() as AnyObject).value(forKeyPath: "token") as? String,
            let datasetId = (command.getParameter() as AnyObject).value(forKeyPath: "datasetId") as? UInt64 else {
            command.reject(errorMessage: "no token or datasetId")
            return
        }
        EinsteinVision.instance.models(token: token, datasetId: datasetId, onSuccess: { (value) in
            command.resolve(value: value)
        }) { (error) in
            command.reject(errorMessage: error)
        }
    }
    
    public class func processHapticFeedbackInit(command: Command) {
        let _ = HapticFeedback.instance
        command.resolve(value: true)
    }
    
    public class func processHapticFeedbackExecute(command: Command) {
        if let type = (command.getParameter() as AnyObject).value(forKeyPath: "type") as? String {
            HapticFeedback.instance.feedback(type: type, onSuccess: { (result) in
                command.resolve(value: result)
            }, onFail: { (errorMessage) in
                command.reject(errorMessage: errorMessage)
            })
        } else {
            command.reject(errorMessage: "type parameter is not specified")
        }
    }
    
    public class func checkLogAccess( command: Command ) {
        processLogAccess( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processLogAccess( command: Command, onSuccess: @escaping((Any)->()), onFail: @escaping((String)->()) ) {
        if let id = SystemSettings.instance.get(key: "id") as? Int,
        let mobile_id = SystemSettings.instance.get(key: "mobile_id") as? Int,
        let appversion = SystemSettings.instance.get(key: "mobile_appversion") as? Double,
        let mobile_gps = SystemSettings.instance.get(key: "mobile_gps") as? String {
            let parameters = NSMutableDictionary()
            parameters.setValue( "POST", forKey: "method")
            parameters.setValue( "http://luna-10.herokuapp.com/logaccess", forKey: "url")
            let headers = NSMutableDictionary()
            headers.setValue( "application/json", forKey: "Content-Type")
            headers.setValue( "application/json", forKey: "Accept")
            parameters.setValue( headers, forKey: "headers")
            let data = NSMutableDictionary()
            data.setValue( id, forKey: "userid")
            data.setValue( mobile_id, forKey: "deviceid")
            data.setValue( mobile_gps, forKey: "gps")
            data.setValue( appversion, forKey: "appversion")
            parameters.setValue( data, forKey: "data")
            let command = Command( commandCode: CommandCode.HTTP_POST, parameter: parameters )
            command.onResolve { ( result ) in
                onSuccess( result )
            }
            command.onReject { (error) in
                onFail( error )
            }
            CommandProcessor.queue(command: command)
        } else {
            onFail("No userid or mobile id")
        }
    }

	public class func checkSystemSettings( command: Command ) {
		procesSystemSettings( command: command, onSuccess: { result in
			command.resolve( value: result )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	public class func procesSystemSettings( command: Command, onSuccess: ((NSDictionary)->()), onFail: ((String)->()) ){
		onSuccess( SystemSettings.instance.getSystemSettings() )
	}

	public class func checkSystemSettingsSet( command: Command ) {
		checkSystemSettingsSet( command: command, onSuccess: { result in
			command.resolve( value: result )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func checkSystemSettingsSet( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
		if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String,
			let value = (command.getParameter() as AnyObject).value(forKeyPath: "value") as Any? {
			SystemSettings.instance.set(key: key, value: value)
			onSuccess( true )
		} else {
			onFail( FileError.INVALID_PARAMETERS.localizedDescription )
		}
	}

    public class func checkUserSettingsDelete( command: Command ) {
        checkUserSettingsDelete( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsDelete( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String {
            UserSettings.instance.delete(key: key, onSuccess:onSuccess, onFail:onFail)
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
        }
    }
    
    public class func checkUserSettingsGet( command: Command ) {
        checkUserSettingsGet( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsGet( command: Command, onSuccess: @escaping((Any)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String {
            if let value = UserSettings.instance.get(key: key) {
                onSuccess( value )
                return
            } else {
                onFail( "key does not exists" )
                return
            }
        }
        onFail( FileError.INVALID_PARAMETERS.localizedDescription )
    }
    
    public class func checkUserSettingsSet( command: Command ) {
        checkUserSettingsSet( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsSet( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String,
            let value = (command.getParameter() as AnyObject).value(forKeyPath: "value") as Any? {
            UserSettings.instance.set(key: key, value: value)
            onSuccess( true )
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
        }
    }
    
    public class func checkWebViewRecieveMessage( command: Command ) {
        getCommand(commandCode: CommandCode.WEB_VIEW_POSTMESSAGE) { (cmd) in
            if let isSendUntilRecieved = (cmd.getParameter() as AnyObject).value(forKeyPath: "isSendUntilRecieved") as? Bool {
                if isSendUntilRecieved {
                    checkWebViewPostMessage( command: cmd, isSysSent: true )
                }
            }
        }
    }
    
    public class func checkWebViewPostMessage( command: Command, isSysSent:Bool?=false ) {
        processWebViewPostMessage( command: command, isSysSent:isSysSent!, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func processWebViewPostMessage( command: Command, isSysSent:Bool, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
        var isSent = false
        if let isSendToAll = (command.getParameter() as AnyObject).value(forKeyPath: "isSendToAll") as? Bool, let message = (command.getParameter() as AnyObject).value(forKeyPath: "message") as? String {
            getCommand(commandCode: CommandCode.WEB_VIEW_RECIEVEMESSAGE) { (recievecommand) in
                if isSendToAll {
                    recievecommand.update(value: message)
                    isSent = true
                } else {
                    if command.getTargetWebViewID() == recievecommand.getSourceWebViewID() {
                        recievecommand.update(value: message)
                        isSent = true
                    }
                }
            }
        }
        let isSendUntilRecieved = ((command.getParameter() as AnyObject).value(forKeyPath: "isSendUntilRecieved") as? Bool) ?? false
        
        if (!(isSendUntilRecieved) || isSysSent) {
            if isSent {
                onSuccess(true)
            } else {
                onFail("Unable to deliver message")
            }
        }
    }
    
    public class func checkUserSettingsLunaSettingsHtml( command: Command ) {
        processUserSettingsLunaSettingsHtml( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processUserSettingsLunaSettingsHtml( command: Command, onSuccess: ((NSDictionary, HtmlFile)->()), onFail: ((String)->()) ){
        let htmlFile = SettingsPage.instance.getPage()
        onSuccess( htmlFile.toDictionary(), htmlFile )
    }
    
    public class func checkUserNotification( command: Command ) {
        processUserNotification( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processUserNotification( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        UserNotification.instance.requestAuthorization( isPermitted: { result in
            if( result ) {
                onSuccess( true )
            } else {
                onFail("Notifications disabled")
            }
        })
    }
    
    public class func checkUserNotificationShowMessage( command: Command ) {
        processUserNotificationShowMessage( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processUserNotificationShowMessage( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        let content = UNMutableNotificationContent()
        let requestIdentifier = "LunaNotification\(command.getCommandID())"
        print( requestIdentifier )
        
        if let badge = (command.getParameter() as AnyObject).value(forKeyPath: "badge") as? NSNumber {
            content.badge = badge
        }
        if let title = (command.getParameter() as AnyObject).value(forKeyPath: "title") as? String {
            content.title = title
        }
        if let subtitle = (command.getParameter() as AnyObject).value(forKeyPath: "subtitle") as? String {
            content.subtitle = subtitle
        }
        if let body = (command.getParameter() as AnyObject).value(forKeyPath: "body") as? String {
            content.body = body
        }
        
        var options = [UNNotificationAction]()
        if let opts = (command.getParameter() as AnyObject).value(forKeyPath: "choices") as? [NSDictionary] {
            var hasOptions = false
            for (_, option) in opts.enumerated() {
                if let value = option.value(forKeyPath: "value") as? String, let title = option.value(forKeyPath: "title") as? String {
                    hasOptions = true
                    options.append(UNNotificationAction(identifier: value, title: title, options: [.foreground]))
                }
                
            }
            if hasOptions {
                let category = UNNotificationCategory(identifier: "LunaActionCategory\(command.getCommandID())", actions: options, intentIdentifiers: [], options: [])
                
                UNUserNotificationCenter.current().setNotificationCategories([category])
                content.categoryIdentifier = "LunaActionCategory\(command.getCommandID())"
                
                print( "LunaActionCategory\(command.getCommandID())" )
            }
        }
        
        content.sound = UNNotificationSound.default()
        
        // If you want to attach any image to show in local notification
        var imgAttachment:ImageFile?
        do {
            imgAttachment = try ImageFile(fileId: File.generateID(), bundle: "luna.jpg", path: "resource/img")
            let attachment = try? UNNotificationAttachment(identifier: requestIdentifier, url: imgAttachment!.getFilePath()!, options: nil)
            content.attachments = [attachment!]
        } catch {}
        
        var timeInterval = ((command.getParameter() as AnyObject).value(forKeyPath: "timeInterval") as? Double ) ?? 0.5
        if timeInterval < 0.5 {
            timeInterval = 0.5
        }
        let isRepeating = ((command.getParameter() as AnyObject).value(forKeyPath: "repeat") as? Bool ) ?? false
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: timeInterval, repeats: isRepeating)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            
            if error != nil {
                onFail(error!.localizedDescription)
                return
            }
            //print("Notification Register Success")
            onSuccess(true)
        }
    }
    
    public class func checkHttpPost( command: Command ) {
        processHttpPost( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func processHttpPost( command: Command, onSuccess: @escaping((NSDictionary)->()), onFail: @escaping((String)->()) ) {
        guard let urlString = ((command.getParameter() as AnyObject).value(forKeyPath: "url") as? String ),
              let method = ((command.getParameter() as AnyObject).value(forKeyPath: "method") as? String ) else {
            onFail( "paramters missing" )
            return
        }
        let headers = (command.getParameter() as AnyObject).value(forKeyPath: "headers") as? NSDictionary
        let data = (command.getParameter() as AnyObject).value(forKeyPath: "data") as? NSDictionary
        let multipart = (command.getParameter() as AnyObject).value(forKeyPath: "multipart") as? NSDictionary
        Ajax.instance.request(urlString: urlString, method: method, data: data, multipart: multipart, headers: headers, onSuccess: onSuccess, onFail: onFail)
    }


    public class func checkSFServiceLiveAgentInit( command: Command ) {
        //https://developer.salesforce.com/docs/atlas.en-us.noversion.service_sdk_ios.meta/service_sdk_ios/live_agent_prechat_fields.htm
        processSFServiceLiveAgentInit( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processSFServiceLiveAgentInit( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if let buttonId = (command.getParameter() as AnyObject).value(forKeyPath: "buttonId") as? String,
            let liveAgentPod = (command.getParameter() as AnyObject).value(forKeyPath: "liveAgentPod") as? String,
            let orgId = (command.getParameter() as AnyObject).value(forKeyPath: "orgId") as? String,
            let deploymentId = (command.getParameter() as AnyObject).value(forKeyPath: "deploymentId") as? String {
            
            let visitorName = (command.getParameter() as AnyObject).value(forKeyPath: "visitorName") as? String ?? "Guest User"
            
            SFServiceLiveAgent.instance.instantiate(liveAgentPod: liveAgentPod, orgId: orgId, deploymentId: deploymentId, buttonId: buttonId, visitorName: visitorName, onSuccess: onSuccess, onFail: onFail)
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )//msaito@electra.demo
        }
        
        
    }
    
    public class func checkSFServiceLiveAgentAddPrechatObject( command: Command ) {
        processSFServiceLiveAgentAddPrechatObject( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processSFServiceLiveAgentAddPrechatObject( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if let prechatObject = (command.getParameter() as AnyObject).value(forKeyPath: "prechatObject") as? NSDictionary {
            SFServiceLiveAgent.instance.addPrechatObject(prechatObject: prechatObject, onSuccess: onSuccess, onFail: onFail)
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
        }
    }
    
    public class func checkSFServiceLiveAgentClearPrechatObject( command: Command ) {
        processSFServiceLiveAgentClearPrechatObject( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processSFServiceLiveAgentClearPrechatObject( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        SFServiceLiveAgent.instance.clearPrechatObject(onSuccess: onSuccess, onFail: onFail)
    }
    
    public class func checkSFServiceLiveAgentCheckAvailability( command: Command ) {
        processSFServiceLiveAgentCheckAvailability( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processSFServiceLiveAgentCheckAvailability( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        SFServiceLiveAgent.instance.checkAvailability(onSuccess: onSuccess, onFail: onFail)
    }
    
    public class func checkSFServiceLiveAgentStart( command: Command ) {
        processSFServiceLiveAgentStart( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processSFServiceLiveAgentStart( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        SFServiceLiveAgent.instance.start(onSuccess: onSuccess, onFail: onFail)
    }
    
    public class func checkSFServiceSOSInit( command: Command ) {
        processSFServiceSOSInit( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processSFServiceSOSInit( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        let _ = SFServiceSOS.instance.getInstance()
        onSuccess( true )
    }
    
    public class func processSFServiceSOSstateChange( value: NSDictionary) {
        getCommand(commandCode: .SF_SERVICESOS_STATECHANGE) { (command) in
            command.update(value: value)
        }
    }
    public class func processSFServiceSOSdidConnect(){
        getCommand(commandCode: .SF_SERVICESOS_DIDCONNECT) { (command) in
            command.update(value: true)
        }
    }
    public class func processSFServiceSOSdidStop( value: NSDictionary) {
        getCommand(commandCode: .SF_SERVICESOS_DIDSTOP) { (command) in
            command.update(value: value)
        }
    }
    
    public class func checkSFServiceSOSStart( command: Command ) {
        processSFServiceSOSStart( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processSFServiceSOSStart( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if let isautoConnect = (command.getParameter() as AnyObject).value(forKeyPath: "autoConnect") as? Bool,
            let email = (command.getParameter() as AnyObject).value(forKeyPath: "email") as? String,
            let pod = (command.getParameter() as AnyObject).value(forKeyPath: "pod") as? String,
            let org = (command.getParameter() as AnyObject).value(forKeyPath: "org") as? String,
            let deployment = (command.getParameter() as AnyObject).value(forKeyPath: "deployment") as? String {
            SFServiceSOS.instance.getInstance().start( isautoConnect:isautoConnect, email: email, pod: pod, org: org, deployment: deployment, onSuccess: onSuccess, onFail: onFail)
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
        }
    }
    
    public class func checkSFServiceSOSStop( command: Command ) {
        processSFServiceSOSStop( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processSFServiceSOSStop( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        SFServiceSOS.instance.getInstance().stop(onSuccess: onSuccess, onFail: onFail)
    }

    public class func processSFServiceLiveAgentstateChange( value: NSDictionary) {
        getCommand(commandCode: .SF_SERVICELIVEA_STATECHANGE) { (command) in
            command.update(value: value)
        }
    }
    public class func processSFServiceLiveAgentDidend( value: NSDictionary) {
        getCommand(commandCode: .SF_SERVICELIVEA_DIDEND) { (command) in
            command.update(value: value)
        }
    }
}
