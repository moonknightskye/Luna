//
//  WKWebView+extension.swift
//  Luna
//
//  Created by Mart Civil on 2017/02/21.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    
    convenience init( webview_id:Int ) {
        let contentController = WKUserContentController()
        contentController.add(
            Shared.shared.ViewController,
            name: "webcommand"
        )
        
        WKWebView.appendJavascript( script:WKWebView.generateJavaScript(commandName: "init", params: webview_id), contentController: contentController )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.init( frame:UIScreen.main.bounds, configuration: config )
        self.addObserver(self, forKeyPath: #keyPath(WKWebView.loading), options: .new, context: nil)
        self.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        self.isOpaque = false
    }
    
    func load( bundlefilePath:URL, onSuccess:(()->())?=nil, onFail:((String)->())?=nil ){
        self.load( NSURLRequest(url: bundlefilePath) as URLRequest )
        if onSuccess != nil {
            onSuccess!()
        }
    }
    
    func load( docfilePath:URL, onSuccess:(()->())?=nil, onFail:((String)->())?=nil ){
        self.loadFileURL( docfilePath, allowingReadAccessTo: FileManager.getDocumentsDirectoryPath()! )
        if onSuccess != nil {
            onSuccess!()
        }
    }
    
    func load( url:URL, onSuccess:(()->())?=nil, onFail:((String)->())?=nil ){
        self.load( URLRequest( url: url ) )
        if onSuccess != nil {
            onSuccess!()
        }
    }
    
    private class func appendJavascript( script:String, contentController:WKUserContentController ) {
        contentController.addUserScript(
            WKUserScript(
                source: script,
                injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                forMainFrameOnly: true
            )
        )
    }
    
    private class func generateJavaScript( commandName:String, params: Any?=nil ) -> String {
        let command:NSMutableDictionary = NSMutableDictionary()
        command.setValue( commandName, forKey: "command" );
        if( params != nil ) {
            command.setValue(params, forKey: "params")
        }
        return "(function(){ iOS.runJSCommand('\(Utility.shared.dictionaryToJSON(dictonary: command))'); })();"
    }
    
    func runJSCommand( commandName:String, params: NSDictionary, onComplete:((Any?, Error?)->Void)?=nil ) {
        let script = WKWebView.generateJavaScript( commandName: commandName, params: params )
        self.evaluateJavaScript( script, completionHandler: onComplete )
    }
    

    
    
    func getManager() -> WebViewManager? {
        return WebViewManager.getManager( webview: self )
    }
    
    
    open func removeFromSuperview( onSuccess:(()->())?=nil ) {
        if self.observationInfo != nil {
            self.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            self.removeObserver(self, forKeyPath: #keyPath(WKWebView.loading))
        }
        //self.load(url: URL(string:"about:blank")!)
        super.removeFromSuperview()
        if onSuccess != nil {
            onSuccess!()
        }
    }
    
    func setProperty( property: NSDictionary, animation: NSDictionary?=nil, onSuccess:((Bool)->())?=nil ) {
        if animation != nil {
            var duration = 0.0
            if let duration_val = animation!.value(forKey: "duration") as? Double {
                duration = duration_val
            }
            var delay = 0.0
            if let delay_val = animation!.value(forKey: "delay") as? Double {
                delay = delay_val
            }
            UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.setProperty(property: property)
            }, completion: { finished in
                if onSuccess != nil {
                    onSuccess!( finished )
                }
            })
        } else {
            self.setProperty(property: property)
            if onSuccess != nil {
                onSuccess!( true )
            }
        }
    }
    
    private func setProperty( property: NSDictionary ) {
        if let frame = property.value(forKeyPath: "frame") as? NSDictionary {
            if let width = frame.value(forKeyPath: "width") as? CGFloat {
                self.frame.size.width = width
            }
            if let height = frame.value(forKeyPath: "height") as? CGFloat {
                self.frame.size.height = height
            }
            if let x = frame.value(forKeyPath: "x") as? CGFloat {
                self.frame.origin.x = x
            }
            if let y = frame.value(forKeyPath: "y") as? CGFloat {
                self.frame.origin.y = y
            }
        }
        if let alpha = property.value(forKeyPath: "opacity") as? CGFloat {
            self.alpha = alpha
        }
        if let isOpaque = property.value(forKeyPath: "isOpaque") as? Bool {
            self.isOpaque = isOpaque;
        }
    }
    
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else { return }
        guard let change = change else { return }
        
        if let wkmanager = self.getManager() {
            switch keyPath {
            case "loading": // new:1 or 0
                if let val = change[.newKey] as? Bool {
                    if val {
                        wkmanager.onLoad()
                    } else {
                        if self.estimatedProgress == 1 {
                            //self.removeObserver(self, forKeyPath: #keyPath(WKWebView.loading))
                            wkmanager.onLoaded()
                        }
                    }
                }
            case "estimatedProgress":
                wkmanager.onLoading(progress: self.estimatedProgress * 100)
                if self.estimatedProgress == 1 {
                    //self.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
                }
            default:
                break
            }
        }
    }
}
