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
    
    public class func proccessToggleStatusBar(command: Command) {
        if let isHide = (command.getParameter() as AnyObject).value(forKeyPath: "value") as? Bool {
            Shared.shared.statusBarShouldBeHidden = isHide
            
            if let animation = (command.getParameter() as AnyObject).value(forKeyPath: "animation") as? String {
                var statusBarAnimation:UIStatusBarAnimation;
                switch( animation ) {
                case "slide":
                    statusBarAnimation = .slide
                    break
                case "fade":
                    statusBarAnimation = .fade
                    break
                default:
                    statusBarAnimation = .none
                }
                Shared.shared.statusBarAnimation = statusBarAnimation
            }
            var duration = 0.0
            if let _duration = (command.getParameter() as AnyObject).value(forKeyPath: "duration") as? Double {
                duration = _duration
            }
            
            if let color = (command.getParameter() as AnyObject).value(forKeyPath: "color") as? String {
                if color == "white" {
                    Shared.shared.statusBarStyle = .lightContent
                } else {
                    Shared.shared.statusBarStyle = .default
                }
            }

            //https://stackoverflow.com/questions/45421548/ios-wkwebview-status-bar-padding
            //https://ayogo.com/blog/ios11-viewport/
            
            UIView.animate(withDuration: duration) {
                Shared.shared.ViewController.setNeedsStatusBarAppearanceUpdate()
//                print(Utility.shared.statusBarHeight())
//                print(UIScreen.main.bounds.height)
                command.resolve(value: true)
            }
        } else {
            command.reject(errorMessage: "Value is parameter is not specified")
        }
    }
    
    public class func processToggleAutoSleep(command: Command) {
        if let value = (command.getParameter() as AnyObject).value(forKeyPath: "value") as? Bool {
            UIApplication.shared.isIdleTimerDisabled = value
            command.resolve(value: true)
        } else {
            command.reject(errorMessage: "Value is parameter is not specified")
        }
    }
    
    public class func checkiBeaconInit( command: Command ) {
        processiBeaconInit( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconInit( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        iBeacon.instance.checkPermissionAction = { isPermitted in
            if isPermitted {
                iBeacon.instance.isAccessPermitted = true
                onSuccess( true )
            } else {
                onFail("Scanning denied")
            }
        }
        if( !iBeacon.instance.isAccessPermitted ) {
            iBeacon.instance.requestAuthorization(status: .authorizedAlways)
        } else {
            iBeacon.instance.checkPermissionAction?(true)
        }
    }

    public class func checkiBeaconTransmit( command: Command ) {
        processiBeaconTransmit( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconTransmit( command: Command, onSuccess: @escaping((NSDictionary)->()), onFail: @escaping((String)->()) ) {
        if let regiondict = (command.getParameter() as AnyObject).value(forKeyPath: "region") as? NSDictionary {
            if let region = iBeacon.instance.getBeaconRegion(from: regiondict) {
                iBeacon.instance.transmitiBeacon(region: region, onSuccess: onSuccess, onFail: onFail)
            } else {
                onFail("Invalid region")
            }
        }
    }
    
    public class func checkiBeaconStop( command: Command ) {
        processiBeaconStop( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconStop( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        iBeacon.instance.stopiBeacon(onSuccess: onSuccess, onFail: onFail)
    }
    
    public class func checkiBeaconRangingScanner( command: Command ) {
        processiBeaconRangingScanner( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconRangingScanner( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if let regionsdict = (command.getParameter() as AnyObject).value(forKeyPath: "regions") as? [NSDictionary] {
            iBeacon.instance.startiBeaconRangingScanner(regions: iBeacon.instance.getBeaconRegion(from: regionsdict), onSuccess: onSuccess, onFail: onFail)
        } else {
            onFail("Invalid regions")
        }
    }
    public class func checkiBeaconStopRangingScanner( command: Command ) {
        processiBeaconStopRangingScanner( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconStopRangingScanner( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if let regionsdict = (command.getParameter() as AnyObject).value(forKeyPath: "regions") as? [NSDictionary] {
            iBeacon.instance.stopiBeaconRangingScanner(regions: iBeacon.instance.getBeaconRegion(from: regionsdict), onSuccess: onSuccess, onFail: onFail)
        } else {
            onFail("Invalid regions")
        }
    }
    
    public class func checkiBeaconStartMonitoring( command: Command ) {
        processiBeaconStartMonitoring( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconStartMonitoring( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if let regionsdict = (command.getParameter() as AnyObject).value(forKeyPath: "regions") as? [NSDictionary] {
            iBeacon.instance.startiBeaconMonitoringScanner(regions: iBeacon.instance.getBeaconRegion(from: regionsdict), onSuccess: onSuccess, onFail: onFail)
        } else {
            onFail("Invalid regions")
        }
    }
    public class func checkiBeaconStopMonitoring( command: Command ) {
        processiBeaconStopMonitoring( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconStopMonitoring( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if let regionsdict = (command.getParameter() as AnyObject).value(forKeyPath: "regions") as? [NSDictionary] {
            iBeacon.instance.stopiBeaconMonitoringScanner(regions: iBeacon.instance.getBeaconRegion(from: regionsdict), onSuccess: onSuccess, onFail: onFail)
        } else {
            onFail("Invalid regions")
        }
    }
    
    public class func checkiBeaconGetAllBeacons( command: Command ) {
        processiBeaconGetAllBeacons( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconGetAllBeacons( command: Command, onSuccess: @escaping((NSMutableDictionary)->()), onFail: @escaping((String)->()) ) {
        iBeacon.instance.getAllMonitoredBeacons(onSuccess: onSuccess, onFail: onFail)
    }
    
    public class func checkiBeaconStopAllScan( command: Command ) {
        processiBeaconStopAllScan( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processiBeaconStopAllScan( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        iBeacon.instance.stopAlliBeaconScanner(onSuccess: onSuccess, onFail: onFail)
    }
    
    public class func processiBeaconDidUpdate( value: NSDictionary) {
        getCommand(commandCode: .BEACON_DIDUPDATE) { (command) in
            command.update(value: value)
        }
    }
    public class func processiBeaconOnRange( value: [NSDictionary]) {
        getCommand(commandCode: .BEACON_ONRANGE) { (command) in
            command.update(value: value)
        }
    }
    public class func processiBeaconOnMonitor( value: NSMutableDictionary) {
        getCommand(commandCode: .BEACON_ONMONITOR) { (command) in
            command.update(value: value)
        }
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
    
    public class func checkLogAccess( command: Command ) {
        processLogAccess( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    public class func processLogAccess( command: Command, onSuccess: @escaping((Any)->()), onFail: @escaping((String)->()) ) {
        if let id = SystemSettings.instance.get(key: "id") as? Int, let mobile_id = SystemSettings.instance.get(key: "mobile_id") as? Int {
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
    
    public class func checkHttpPost( command: Command ) {
        processHttpPost( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processHttpPost( command: Command, onSuccess: @escaping((NSDictionary)->()), onFail: @escaping((String)->()) ) {
       // if Reachability.isConnectedToNetwork(){
            if let url = ((command.getParameter() as AnyObject).value(forKeyPath: "url") as? String ) {
                var request = URLRequest(url: URL(string: url)!)
                
                let method = ((command.getParameter() as AnyObject).value(forKeyPath: "method") as? String ) ?? "POST"
                request.httpMethod = method
                
                if let parameters = ((command.getParameter() as AnyObject).value(forKeyPath: "data") as? NSDictionary ) {
                    request.httpBody = Utility.shared.dictionaryToJSON(dictonary: parameters).data(using: .utf8)
                }
                if let multipart = ((command.getParameter() as AnyObject).value(forKeyPath: "multipart") as? NSDictionary ) {
                    
                    //let boundary = "Boundary-\(UUID().uuidString)"
                    let boundary = self.createBoundary()
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    
                    let pmtrs = multipart.value(forKeyPath: "parameters") as! NSDictionary
                    let dataUrl = multipart.value(forKeyPath: "dataUrl") as! URL
                    let data = multipart.value(forKeyPath: "data") as! Data
                    let mimeType = multipart.value(forKeyPath: "mimeType") as! String
                    let filename = multipart.value(forKeyPath: "filename") as! String
                    
                    let body = self.createBody(
                        parameters  : pmtrs,
                        boundary    : boundary,
                        dataUrl     : dataUrl,
                        data        : data,
                        mimeType    : mimeType,
                        filename    : filename
                    )
                    request.httpBody = body as Data
                    request.setValue(String(body.length), forHTTPHeaderField: "Content-Length")
                }
                if let header = ((command.getParameter() as AnyObject).value(forKeyPath: "headers") as? NSDictionary ) {
                    for (key, _) in header {
                        request.addValue(header[ key ] as! String, forHTTPHeaderField: key as! String)
                    }
                }
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        // check for fundamental networking error
                        onFail( error!.localizedDescription )
                        //print("error=\(error!)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response!)")
                    }
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        //print("responseString****** = \(responseString)")
                        if let resp = Utility.shared.StringToDictionary(txt: responseString) {
                            onSuccess( resp )
                            return
                        }
                    }
                    print( "NO RESPONSE" )
                    onFail("NO RESPONSE")
                    
                }
                task.resume()
            }
//        }else{
//            onFail("No Internet Connection Available")
//        }
    }
    
    public class func createBody( parameters: NSDictionary,
                                  boundary: String,
                                  dataUrl: URL,
                                  data: Data,
                                  mimeType: String,
                                  filename: String) -> NSMutableData {
        
        //https://github.com/recaius-dev/recaius-swift/blob/master/RecaiusSDKTrial/Recognition/RecognitionAPI.swift
        
        let body = NSMutableData()
        var tempString: String
        tempString = ""
        for (key, value) in parameters {
            tempString += "--\(boundary)\r\n"
            tempString += "Content-Disposition: form-data; name=\"\(key)\";\r\n"
            tempString += "\r\n"
            tempString += String(describing: value)
            tempString += "\r\n"
            body.append(tempString.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            print(tempString)
        }
        
        //  audio/wav
        //  audio/ogg
        //  audio/x-linear
        //  audio/x-m4a
        //  audio/x-adpcm
        //  audio/speex
        
        tempString = ""
        tempString += "--\(boundary)\r\n"
        tempString += "Content-Disposition: form-data; name=\"voice\"; filename=\"test.wav\"\r\n"
        tempString += "Content-Type: application/octet-stream\r\n"
        tempString += "\r\n"
        body.append(tempString.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        body.append(data)
        
        tempString = ""
        tempString += "\r\n"
        tempString += "--\(boundary)--\r\n"
        body.append(tempString.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        return body
    }
    
    public class func createBody2( parameters: NSDictionary,
                    boundary: String,
                    dataUrl: URL,
                    data: Data,
                    mimeType: String,
                    filename: String) -> NSMutableData {
        
        //https://newfivefour.com/swift-form-data-multipart-upload-URLRequest.html
        //https://github.com/recaius-dev/recaius-swift/blob/master/RecaiusSDKTrial/Recognition/RecognitionAPI.swift
        
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")

			print(key)
			print(value)
        }
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"voice\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))


		print(filename)
		print(mimeType)
		print(boundary)

        return body
    }
    
    public class func createBoundary() -> String {
        return "---------------------------\(NSUUID().uuidString)";
    }
    
    public class func createBoundary2() -> String {
        let multipartChars = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let length = Int(30 + floor(Double(arc4random_uniform(10))))
        var boundary = "---------------------------";
        for _ in 0...length {
            let char = multipartChars.charAt(at: Int(  Int(arc4random_uniform(10)) * multipartChars.length ) / 10  )
            boundary.append(char)
        }
        return boundary
    }


	public class func checkAVAudioRecorderInit( command: Command ) {
		processAVAudioRecorderInit( command: command, onSuccess: { result in
			command.resolve( value: result )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func processAVAudioRecorderInit( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {

		let recorder = VoiceRecorder.instance
		recorder.checkPermission(onSuccess: onSuccess, onFail: onFail)
	}

	public class func checkAVAudioRecorderRecord( command: Command ) {
		processAVAudioRecorderRecord( command: command, onSuccess: { result in
			command.resolve( value: result )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func processAVAudioRecorderRecord( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {

		let recorder = VoiceRecorder.instance
		recorder.checkPermission(onSuccess: { (result) in
			recorder.startRecording(onSuccess: onSuccess, onFail: onFail)
		}) { (error) in
			onFail( error )
		}
	}

	public class func checkAVAudioRecorderStop( command: Command ) {
		processAVAudioRecorderStop( command: command, onSuccess: { result, raw in
			command.resolve( value: result, raw: raw )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func processAVAudioRecorderStop( command: Command, onSuccess: @escaping((NSDictionary, File)->()), onFail: @escaping((String)->()) ) {

		let recorder = VoiceRecorder.instance
		recorder.checkPermission(onSuccess: { (result) in
			recorder.stopRecording(onSuccess: { (recordedFile) in
				onSuccess(recordedFile.toDictionary(), recordedFile)
			}, onFail: { (error) in
				onFail( error )
			})
		}) { (error) in
			onFail( error )
		}
	}

	public class func checkAVAudioConvertToWav( command: Command ) {
		processAVAudioConvertToWav( command: command, onSuccess: { result, raw in
			command.resolve( value: result, raw: raw )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func processAVAudioConvertToWav( command: Command, onSuccess: @escaping((NSDictionary, File)->()), onFail: @escaping((String)->()) ) {

		let recorder = VoiceRecorder.instance

		if let audioFile = ((command.getParameter() as AnyObject).value(forKeyPath: "file") as? NSDictionary ) {
			do {
				let file = try File( file: audioFile )
				recorder.convertToWav(audioFile: file, onSuccess: { (encodedFile) in
					onSuccess(encodedFile.toDictionary(), encodedFile)
				}) { (error) in
					onFail(error)
				}
			} catch let error as NSError {
				onFail( error.localizedDescription )
			}

		} else {
			onFail(FileError.INVALID_PARAMETERS.localizedDescription)
		}
	}
    
    public class func processAVAudioRecorderRecording( buffer: Data ) {
        getCommand(commandCode: .AVAUDIO_RECORDER_RECORDING) { (command) in
            command.update(value: Utility.shared.DataToBase64(data: buffer))
        }
    }


}
