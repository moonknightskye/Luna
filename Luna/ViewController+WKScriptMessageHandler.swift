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

extension ViewController: WKScriptMessageHandler {

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
}
