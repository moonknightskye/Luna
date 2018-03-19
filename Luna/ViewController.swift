//
//  ViewController.swift
//  Luna
//
//  Created by Mart Civil on 2017/01/18.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//
// Build Phases/ Run Script/ "${PODS_ROOT}/Fabric/run" 246dfe64d8bb683f7ba9d13b5360af7c3aa6b684 c977ed784ee79b09451f80f42903b1f470ee15b19e9879fad36afb2494e3eacc


import UIKit
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate  {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Shared.shared.ViewController = self
        
        SettingsPage.instance.attachListeners()
        
        Shared.shared.checkAppPermissionsAction = { isAllowed in
            if( isAllowed ) {
                Shared.shared.checkAppPermissionsAction = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.checkCustomURLScheme()
                }
            } else {
                let command = Command(commandCode: CommandCode.OPEN_APP_SETTINGS, priority: .CRITICAL)
                CommandProcessor.queue(command: command)
            }
        }
        
        Utility.shared.executeOnFullPermission { (isPermitted) in
            Shared.shared.checkAppPermissionsAction?( isPermitted )
        }

    }
    
    public func checkCustomURLScheme() {
        if let id = SystemSettings.instance.get(key: "id") as? Int, let logaccess = SystemSettings.instance.get(key: "logaccess") as? Bool {
            let hapticParameter = NSMutableDictionary()
            if id != -1 && logaccess {
                let logaccessCmd = Command( commandCode: CommandCode.LOGACCESS )
                logaccessCmd.onResolve(fn: { (success) in
                    let hapticInit = Command( commandCode: CommandCode.HAPTIC_INIT, priority: .CRITICAL)
                    hapticInit.onResolve(fn: { (success) in
                        hapticParameter.setValue( "success", forKey: "type")
                        let hapticSuccess = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
                        hapticSuccess.onReject(fn: { (message) in
                            hapticParameter.setValue( "pop", forKey: "type")
                            let hapticPop = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
                            CommandProcessor.queue(command: hapticPop)
                        })
                        CommandProcessor.queue(command: hapticSuccess)
                    })
                    CommandProcessor.queue(command: hapticInit)
                })
                CommandProcessor.queue(command: logaccessCmd)
            }
            if id > -1 && !logaccess {
                let hapticInit = Command( commandCode: CommandCode.HAPTIC_INIT, priority: .CRITICAL )
                hapticInit.onResolve(fn: { (success) in
                    hapticParameter.setValue( "error", forKey: "type")
                    let hapticError = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
                    hapticError.onReject(fn: { (message) in
                        hapticParameter.setValue( "nope", forKey: "type")
                        let hapticNope = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
                        CommandProcessor.queue(command: hapticNope)
                    })
                    CommandProcessor.queue(command: hapticError)
                })
                CommandProcessor.queue(command: hapticInit)
                DispatchQueue.main.async {
                    HapticFeedback.instance.feedback(type: "error", onSuccess: { (result) in }, onFail: { (error) in
                        HapticFeedback.instance.feedback(type: "nope", onSuccess: { (result) in }, onFail: { (error) in })
                    })
                }
            }
        }
        
        if let customURLScheme = Shared.shared.customURLScheme {
            if let startup_page = customURLScheme.queryItems["startup_page"] {
                UserSettings.instance.setShowSplashScreen(show: false)
                UserSettings.instance.setStartupEnabled(enabled: true)
                UserSettings.instance.setStartupPage(fileName: startup_page)
                UserSettings.instance.setPathType(pathType: "URL")
            } else {
                let userNotification = Command( commandCode: CommandCode.USER_NOTIFICATION )
                userNotification.onResolve(fn: { (success) in
                    let parameter = NSMutableDictionary()
                    parameter.setValue( "Failed to load Startup Page", forKey: "title")
                    parameter.setValue( "startup_page not set as a parameter in URL Scheme", forKey: "body")
                    parameter.setValue( 0, forKey: "badge")
                    parameter.setValue( Double(0.5), forKey: "timeInterval")
                    parameter.setValue( false, forKey: "repeat")
                    let userNotificationMsg = Command( commandCode: CommandCode.USER_NOTIFICATION_SHOWMSG, parameter: parameter )
                    CommandProcessor.queue(command: userNotificationMsg)
                })
                CommandProcessor.queue(command: userNotification)
            }
        }
        
        loadDefaultView()
    }
    
    public func loadDefaultView() {
        if UserSettings.instance.isShowSplashScreen() {
            let parameter = NSMutableDictionary()
            parameter.setValue( "splash.html", forKey: "filename")
            parameter.setValue( "resource", forKey: "path")
            parameter.setValue( "bundle", forKey: "path_type")
            
            let commandGetFile = Command( commandCode: CommandCode.GET_HTML_FILE, parameter: parameter, priority: .CRITICAL )
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
    
    private func loadStartupPage( htmlFile: HtmlFile, errorMessage:String?=nil ) {
        let parameter = NSMutableDictionary()
        parameter.setValue( htmlFile, forKey: "html_file")
        let property = NSMutableDictionary()
        property.setValue( CGFloat(0.0), forKey: "opacity")
        parameter.setValue( property, forKey: "property")
        
        let command = Command(commandCode: CommandCode.NEW_WEB_VIEW, parameter: parameter, priority: .CRITICAL)
        command.onResolve { (webview_id) in
            let cmdproperty = NSMutableDictionary()
            cmdproperty.setValue( webview_id, forKey: "webview_id")
            
            let commandOnLoading = Command(commandCode: CommandCode.WEB_VIEW_ONLOADING, targetWebViewID: webview_id as? Int, parameter: cmdproperty, priority: .CRITICAL)
            commandOnLoading.onUpdate(fn: { (progress) in
                print( "Loading... \(progress)%" )
            })
            CommandProcessor.queue(command: commandOnLoading)
            
            let commandOnLoaded = Command(commandCode: CommandCode.WEB_VIEW_ONLOADED, targetWebViewID: webview_id as? Int, parameter: cmdproperty, priority: .CRITICAL)
            commandOnLoaded.onUpdate(fn: { (result) in
                
                if let isSuccess = (result as AnyObject).value(forKeyPath: "success") as? Bool {
                    
                    Shared.shared.isAppLoaded = true
                    
                    if isSuccess {
                        let setpropparam = NSMutableDictionary()
                        let propparam = NSMutableDictionary()
                        propparam.setValue( CGFloat(1.0), forKey: "opacity")
                        let animaparam = NSMutableDictionary()
                        animaparam.setValue( Double(0.6), forKey: "duration")
                        setpropparam.setValue( propparam, forKey: "property")
                        setpropparam.setValue( animaparam, forKey: "animation")
                        let commandSetProperty = Command(commandCode: CommandCode.ANIMATE_WEB_VIEW, targetWebViewID: Int(webview_id as! Int), parameter: setpropparam, priority: .CRITICAL)
                        commandSetProperty.onResolve(fn: { (result) in
                            
                            //AR_BACK.instance.run()
                            
                            if errorMessage != nil {
                                let messageprop = NSMutableDictionary()
                                messageprop.setValue( "[ERROR] " + errorMessage!, forKey: "message")
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
                Command( commandCode: CommandCode.LOAD_WEB_VIEW, targetWebViewID: webview_id as? Int, priority: .CRITICAL )
            )
        }
        command.onReject { (message) in
            print( message )
        }
        CommandProcessor.queue(command: command)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Shared.shared.statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return Shared.shared.statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return Shared.shared.statusBarAnimation
    }
    
    @objc func screenEdgeSwipedOneFinger(_ recognizer: UIGestureRecognizer) {
        if let swipeGesture = recognizer as? UISwipeGestureRecognizer {
            CommandProcessor.processSwipeGesture(swipeDirection: swipeGesture.direction, touchesRequired: 1)
        }
    }
    
    
    @objc func screenEdgeSwipedTwoFingers(_ recognizer: UIGestureRecognizer) {
        if let swipeGesture = recognizer as? UISwipeGestureRecognizer {
            CommandProcessor.processSwipeGesture(swipeDirection: swipeGesture.direction, touchesRequired: 2)
        }
    }
    
    @objc func screenEdgeSwipedThreeFingers(_ recognizer: UIGestureRecognizer) {
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
}
