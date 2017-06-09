//
//  SettingsPage.swift
//  Luna
//
//  Created by Mart Civil on 2017/06/05.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import WebKit
import Foundation

public enum SettingsActivation:String {
    case SHAKE_1            = "Shake 1 time or greater"
    case SHAKE_2            = "Shake 3 times or greater"
    case SHAKE_3            = "Shake 6 times or greater"
    case EDGE_SWIPE_RIGHT_1 = "1-finger right edge swipe"
    case EDGE_SWIPE_RIGHT_2 = "2-finger right edge swipe"
    case EDGE_SWIPE_RIGHT_3 = "3-finger right edge swipe"
    case EDGE_SWIPE_LEFT_1  = "1-finger left edge swipe"
    case EDGE_SWIPE_LEFT_2  = "2-finger left edge swipe"
    case EDGE_SWIPE_LEFT_3  = "3-finger left edge swipe"
}

class SettingsPage {
    static let instance:SettingsPage = SettingsPage()
    let activation:SettingsActivation!
    
    public init() {
        activation = SettingsActivation(rawValue: UserSettings.instance.getShowSettingsOn())
    }
    
    func attachListeners() {
        let parameter = NSMutableDictionary()
        parameter.setValue( false, forKey: "isCanBeDeactivated")
        
        let command:Command!
        
        switch activation! {
        case .EDGE_SWIPE_LEFT_1,
             .EDGE_SWIPE_LEFT_2,
             .EDGE_SWIPE_LEFT_3,
             .EDGE_SWIPE_RIGHT_1,
             .EDGE_SWIPE_RIGHT_2,
             .EDGE_SWIPE_RIGHT_3:
            
            switch activation! {
            case .EDGE_SWIPE_LEFT_1,
                 .EDGE_SWIPE_LEFT_2,
                 .EDGE_SWIPE_LEFT_3:
                parameter.setValue( "left", forKey: "direction")
                break
            default:
                parameter.setValue( "right", forKey: "direction")
                break
            }
            
            switch activation! {
            case .EDGE_SWIPE_LEFT_2,
                 .EDGE_SWIPE_RIGHT_2:
                parameter.setValue( 2, forKey: "touchesRequired")
                break
            case .EDGE_SWIPE_LEFT_3,
                 .EDGE_SWIPE_RIGHT_3:
                parameter.setValue( 3, forKey: "touchesRequired")
                break
            default:
                parameter.setValue( 1, forKey: "touchesRequired")
                break
            }
            
            command = Command( commandCode: CommandCode.SCREEN_EDGE_SWIPED, parameter: parameter )
            command.onUpdate { (result) in
                self.showSettingsPage()
            }
            
            break
        case .SHAKE_1,
             .SHAKE_2,
             .SHAKE_3:
            
            var count:Double = -1.0
            switch activation! {
            case .SHAKE_1:
                count = 0.0
                break
            case .SHAKE_2:
                count = 0.7
                break
            default:
                count = 1.4
                break
            }
            
            var shakeStart:Date?
            let commandShake = Command( commandCode: CommandCode.SHAKE_BEGIN, parameter: parameter )
            commandShake.onUpdate { (result) in
                shakeStart = Date()
            }
            CommandProcessor.queue(command: commandShake)
            
            command = Command( commandCode: CommandCode.SHAKE_END, parameter: parameter )
            command.onUpdate { (result) in
                if (shakeStart!.timeIntervalSinceNow * -1 ) >= count {
                    self.showSettingsPage()
                }
            }
            break
        }
        
        CommandProcessor.queue(command: command)
    }
    
    
    func getPage() -> HtmlFile {
        var settingPage:HtmlFile?
        do {
            settingPage = try HtmlFile(
                fileId: File.generateID(),
                bundle: "settings.html",
                path: "resource")
        } catch {}
        return settingPage!
    }
    
    func canShow() -> Bool {
        for(_, subview) in Shared.shared.ViewController.view.subviews.enumerated() {
            if subview is WKWebView {
                if let manager = WebViewManager.getManager(webview: subview as? WKWebView) {
                    let htmlFile = manager.getHTMLFile()
                    if htmlFile.getPathType() == FilePathType.BUNDLE_TYPE, let fileName = htmlFile.getFileName() {
                        if ["settings.html"].contains(fileName) {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    
    func showSettingsPage() {
        if canShow() {
            let parameter = NSMutableDictionary()
            parameter.setValue( self.getPage(), forKey: "html_file")
            let propertyBefore = NSMutableDictionary()
            let propertyAfter = NSMutableDictionary()
            parameter.setValue( propertyBefore, forKey: "property")
            propertyBefore.setValue( CGFloat(0.0), forKey: "opacity")
            propertyAfter.setValue( CGFloat(1.0), forKey: "opacity")
            
            let frameBefore = NSMutableDictionary()
            let frameAfter = NSMutableDictionary()
            propertyBefore.setValue( frameBefore, forKey: "frame")
            propertyAfter.setValue( frameAfter, forKey: "frame")
            
            switch activation! {
            case .EDGE_SWIPE_LEFT_1,
                 .EDGE_SWIPE_LEFT_2,
                 .EDGE_SWIPE_LEFT_3:
                frameBefore.setValue(CGFloat(0 + Shared.shared.ViewController.view.frame.width), forKey: "x")
                frameAfter.setValue(CGFloat(0), forKey: "x")
                break
            case .EDGE_SWIPE_RIGHT_1,
                 .EDGE_SWIPE_RIGHT_2,
                 .EDGE_SWIPE_RIGHT_3:
                frameBefore.setValue(CGFloat(0 - Shared.shared.ViewController.view.frame.width), forKey: "x")
                frameAfter.setValue(CGFloat(0), forKey: "x")
                break
            case .SHAKE_1,
                 .SHAKE_2,
                 .SHAKE_3:
                frameBefore.setValue(CGFloat(0 + Shared.shared.ViewController.view.frame.height), forKey: "y")
                frameAfter.setValue(CGFloat(0), forKey: "y")
                break
            }

            
            
            let command = Command(commandCode: CommandCode.NEW_WEB_VIEW, parameter: parameter)
            command.onResolve { (webview_id) in
                let cmdproperty = NSMutableDictionary()
                cmdproperty.setValue( webview_id, forKey: "webview_id")
                
                let commandOnLoaded = Command(commandCode: CommandCode.WEB_VIEW_ONLOADED, targetWebViewID: webview_id as? Int, parameter: cmdproperty)
                commandOnLoaded.onUpdate(fn: { (result) in
                    let setpropparam = NSMutableDictionary()
                    let animaparam = NSMutableDictionary()
                    animaparam.setValue( Double(0.2), forKey: "duration")
                    setpropparam.setValue( propertyAfter, forKey: "property")
                    setpropparam.setValue( animaparam, forKey: "animation")
                    let commandSetProperty = Command(commandCode: CommandCode.ANIMATE_WEB_VIEW, targetWebViewID: Int(webview_id as! Int), parameter: setpropparam)
                    CommandProcessor.queue(command: commandSetProperty)
                })
                
                CommandProcessor.queue(command: commandOnLoaded)
                
                CommandProcessor.queue(command:
                    Command( commandCode: CommandCode.LOAD_WEB_VIEW, targetWebViewID: webview_id as? Int )
                )
            }
            CommandProcessor.queue(command: command)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
