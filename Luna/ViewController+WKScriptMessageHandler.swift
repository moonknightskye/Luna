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
                CommandProcessor.queue( command: Command( command: webcommand ) )
            }
        }
    }
}
