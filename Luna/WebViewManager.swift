//
//  WebViewManager.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/01.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//
import Foundation
import WebKit
import AVFoundation

public enum Status:Int {
    case INIT       = 200
    case LOAD       = 201
    case LOADING    = 202
    case LOADED     = 203
}

class WebViewManager {
    
    static var SYSTEM_WEBVIEW = 0
    
    static var LIST:[WebViewManager] = [WebViewManager]();
    static var counter = 0;
    
    private var webview_id = WebViewManager.counter
    private var htmlFile:HTMLFile!
    
    private var webview:WKWebView!
    private var sourceWebViewID:Int!
    private var value:Any!
    private var type:FilePathType!
    private var status:Status!
    
    public init( source_webview_id:Int?=0, htmlFile:HTMLFile ) {
        self.setStatus(status: Status.INIT)
        
        WebViewManager.counter += 1;
        
        self.setHTMLFile(htmlFile: htmlFile)
        self.setType(type: htmlFile.getPathType()!)
        //self.setValue(value: htmlFile)
        self.setWebview(webview: WKWebView(webview_id: self.webview_id))
        self.setSourceWebViewID(sourceWebViewID: source_webview_id!)
        
        WebViewManager.LIST.append(self)
        
        Shared.shared.ViewController.view.addSubview( self.getWebview() )
    }
    
    func load( onSuccess:(()->())?=nil, onFail:((String)->())?=nil ) {
        switch ( self.getType() ) {
        case FilePathType.BUNDLE_TYPE:
            self.getWebview().load( bundlefilePath: self.getHTMLFile().getFilePath()!, onSuccess:onSuccess )
            break;
        case FilePathType.DOCUMENT_TYPE:
            self.getWebview().load( docfilePath: self.getHTMLFile().getFilePath()!, onSuccess:onSuccess )
            break;
        case FilePathType.URL_TYPE:
            self.getWebview().load( url: self.getHTMLFile().getFilePath()!, onSuccess:onSuccess )
            break;
        default:
            if onFail != nil {
                onFail!("Unknown web content")
                return
            }
        }
    }
    
    public func setHTMLFile( htmlFile: HTMLFile ) {
        self.htmlFile = htmlFile
    }
    public func getHTMLFile() -> HTMLFile {
        return self.htmlFile
    }
    
    public func appendAVPlayer( avmanager: AVPlayerManager, isFixed:Bool?=false ) {
        if isFixed! {
            self.getWebview().layer.addSublayer( avmanager.getAVPlayer() )
        } else {
            self.getWebview().scrollView.layer.addSublayer( avmanager.getAVPlayer() )
        }
        if avmanager.isAutoplay(), let player = avmanager.getAVPlayer().player {
            player.play()
        }
    }
    
    public class func getManager( webview_id:Int?=nil, webview:WKWebView?=nil ) -> WebViewManager? {
        for (_, manager) in WebViewManager.LIST.enumerated() {
            if webview_id != nil && manager.getID() == webview_id {
                return manager
            } else if webview != nil && manager.getWebview() == webview {
                return manager
            }
        }
        return nil
    }
    
    public class func removeManager( webview_id:Int?=nil, webview:WKWebView?=nil ) {
        for ( index, manager) in WebViewManager.LIST.enumerated() {
            if webview_id != nil && manager.getID() == webview_id {
                WebViewManager.LIST.remove(at: index)
            } else if webview != nil && manager.getWebview() == webview {
                WebViewManager.LIST.remove(at: index)
            }
        }
    }
    
    func remove() {
        WebViewManager.removeManager(webview_id: self.getID() )
    }
    
    func getID() -> Int {
        return self.webview_id
    }
    
    private func setWebview( webview:WKWebView ) {
        self.webview = webview
    }
    func getWebview() -> WKWebView {
        return self.webview
    }
    
    private func setStatus( status:Status ) {
        self.status = status
    }
    func getStatus() -> Status {
        return self.status
    }
    
    private func setSourceWebViewID( sourceWebViewID: Int ) {
        self.sourceWebViewID = sourceWebViewID
    }
    func getSourceWebViewID() -> Int {
        return self.sourceWebViewID
    }
    
    private func setValue( value:Any ) {
        self.value = value
    }
    func getValue() -> Any {
        return self.value
    }
    
    private func setType( type:FilePathType ) {
        self.type = type
    }
    func getType() -> FilePathType {
        return self.type
    }
    
    func onLoad() {
        CommandProcessor.processWebViewOnload(wkmanager: self)
    }
    
    func onLoaded() {
        CommandProcessor.processWebViewOnLoaded(wkmanager: self)
    }
    
    func onLoading( progress: Double ) {
        CommandProcessor.processWebViewOnLoading(wkmanager: self, progress: progress)
    }
    
    func close( onSuccess: (()->())?=nil) {
        self.getWebview().removeFromSuperview( onSuccess: {
            self.remove()
            if onSuccess != nil {
                onSuccess!()
            }
        } )
    }
}


















