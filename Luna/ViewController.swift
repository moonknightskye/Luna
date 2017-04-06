//
//  ViewController.swift
//  Luna
//
//  Created by Mart Civil on 2017/01/18.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        Shared.shared.ViewController = self
        
        
        var parameter = NSMutableDictionary()
        parameter.setValue( "index.html", forKey: "filename")
        parameter.setValue( "resource", forKey: "path")
        parameter.setValue( "bundle", forKey: "path_type")
        
//        parameter.setValue( "http://techslides.com/demos/video/dragdrop-video-screenshot.html", forKey: "path")
//        parameter.setValue( "url", forKey: "path_type")
        let commandGetFile = Command( commandCode: CommandCode.GET_HTML_FILE, parameter: parameter )
        
        commandGetFile.onResolve { ( htmlFile ) in
            parameter = NSMutableDictionary()
            parameter.setValue( htmlFile, forKey: "html_file")
            let command = Command(commandCode: CommandCode.NEW_WEB_VIEW, parameter: parameter)
            command.onResolve { (webview_id) in
//                let commandOnLoading = Command(commandCode: CommandCode.WEB_VIEW_ONLOADING, targetWebViewID: webview_id as? Int)
//                commandOnLoading.onUpdate(fn: { (progress) in
//                    print( "Loading... \(progress)%" )
//                })
//                CommandProcessor.queue(command: commandOnLoading)
                
                CommandProcessor.queue(command:
                    Command( commandCode: CommandCode.LOAD_WEB_VIEW, targetWebViewID: webview_id as? Int )
                )
                
            }
            command.onReject { (message) in
                print( message )
            }
            CommandProcessor.queue(command: command)
            
        }
        CommandProcessor.queue(command: commandGetFile)
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

