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
    
    public class func checkWebViewPostMessage( command: Command ) {
        processWebViewPostMessage( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processWebViewPostMessage( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
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
        if isSent {
            onSuccess(true)
        } else {
            onFail("Unable to deliver message")
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
        
        //actions defination
        let option1 = UNNotificationAction(identifier: "option1", title: "Action First", options: [.foreground])
        let option2 = UNNotificationAction(identifier: "option2", title: "Action Second", options: [.foreground])
        let option3 = UNNotificationAction(identifier: "option3", title: "Action Third", options: [.foreground])
        
        let category = UNNotificationCategory(identifier: "actionCategory", actions: [option1,option2,option3], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        
        let content = UNMutableNotificationContent()
        let requestIdentifier = "rajanNotification"
        
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
        content.categoryIdentifier = "actionCategory"
        content.sound = UNNotificationSound.default()
        
        // If you want to attach any image to show in local notification
        var imgAttachment:ImageFile?
        do {
            imgAttachment = try ImageFile(fileId: File.generateID(), bundle: "luna.jpg", path: "resource/img")
            let attachment = try? UNNotificationAttachment(identifier: requestIdentifier, url: imgAttachment!.getFilePath()!, options: nil)
            content.attachments = [attachment!]
        } catch {}
        
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.5, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            
            if error != nil {
                onFail(error!.localizedDescription)
                return
            }
            print("Notification Register Success")
            
            onSuccess(true)
        }
    }

}
