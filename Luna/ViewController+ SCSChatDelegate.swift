//
//  ViewController+ SCSChatDelegate.swift
//  Luna
//
//  Created by Mart Civil on 2017/09/14.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import ServiceCore
import ServiceChat

extension ViewController: SCSChatDelegate {

    /**
     Delegate method invoked when a Live Agent Session Ends.
     
     @param chat   `SCSChat` instance which invoked the method.
     @param reason `SCSChatEndReason` describing why the session has ended.
     @param error  `NSError` instance describing the error.
     Error codes can be referenced from `SCSChatErrorCode`.
     @see `SCSChat`
     @see `SCSChatEndReason`
     */
    func chat(_ chat: SCSChat!, didEndWith reason: SCSChatEndReason, error: Error!) {
        print( "CHAT ENDED" )
        print( reason.rawValue )
        print(error)
    }
}
