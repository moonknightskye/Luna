//
//  ViewController+WKScriptMessageHandler.swift
//  Luna
//
//  Created by Mart Civil on 2017/02/21.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UIKit
import WebKit

extension ViewController: WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {

    func userContentController(_ userContentController: WKUserContentController,didReceive message: WKScriptMessage) {
        if message.name == "webcommand" {
            if let webcommand = Utility.shared.StringToDictionary( txt: message.body as! String ) {
                let command = Command( command: webcommand )
                var dispatchQos = DispatchQoS.default
                switch command.getPriority() {
                case .CRITICAL:
					DispatchQueue.global(qos: .userInteractive).async(execute: {
						DispatchQueue.main.async {
							CommandProcessor.queue( command: command )
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
//				DispatchQueue.main.async(group: nil, qos: dispatchQos, flags: .inheritQoS, execute: {
                    CommandProcessor.queue( command: command )
                })
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //print("============== ERROR LOADING ==============")
        //print(error.localizedDescription)
        //CommandProcessor.processWebViewOnLoaded(wkmanager: self)
        if let webview = WebViewManager.getManager(webview: webView) {
            CommandProcessor.processWebViewOnLoaded(wkmanager: webview, isSuccess: false, errorMessage: error.localizedDescription )
        }
        //print("============== ERROR LOADING ==============")
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //print("↓↓↓↓↓↓↓↓↓↓↓↓ START LOADING ↓↓↓↓↓↓↓↓↓↓↓↓")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //print("↑↑↑↑↑↑↑↑↑↑↑↑ FINISH LOADING ↑↑↑↑↑↑↑↑↑↑↑↑")
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void)
    {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "OK", style: .default) {
            action in completionHandler()
        }
        alertController.addAction(otherAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void)
    {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action in completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) {
            action in completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void)
    {
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okHandler: () -> Void = { 
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action in completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) {
            action in okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
