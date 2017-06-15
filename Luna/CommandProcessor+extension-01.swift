//
//  CommandProcessor+extension-01.swift
//  Luna
//
//  Created by Mart Civil on 2017/05/25.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UserNotifications

extension CommandProcessor {
    
//    public class func checkUserSettingsAdd( command: Command ) {
//        checkUserSettingsAdd( command: command, onSuccess: { result in
//            command.resolve( value: result )
//        }, onFail: { errorMessage in
//            command.reject( errorMessage: errorMessage )
//        })
//    }
//    private class func checkUserSettingsAdd( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
//        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String,
//            let value = (command.getParameter() as AnyObject).value(forKeyPath: "value") as Any? {
//            UserSettings.instance.add(key: key, value: value, onSuccess:onSuccess, onFail:onFail)
//        } else {
//            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
//        }
//    }
    
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
        UserNotification.instance.checkAccess(onSuccess:onSuccess, onFail:onFail)
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
            print("Notification Register Success")
            //onSuccess(true)
        }
    }

}
