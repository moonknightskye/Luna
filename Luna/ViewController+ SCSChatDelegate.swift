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
        var code = 0
        var label = ""
        if (error != nil) {
            code = (error as NSError).code
            print("ERROR")
            print(error)
            print(code)
            print(error.localizedDescription)
        } else {
            code = reason.rawValue
        }
        label = SFServiceLiveAgent.instance.getErrorLabel(reason: reason)
        
        let value = NSMutableDictionary()
        value.setValue( code, forKey: "code")
        value.setValue( label, forKey: "label")
        CommandProcessor.processSFServiceLiveAgentDidend( value: value )
    }
    
    
    func chat(_ chat: SCSChat!, stateDidChange current: SCSChatSessionState,
              previous: SCSChatSessionState) {
        let value = NSMutableDictionary()
        value.setValue( current.rawValue, forKey: "code")
        value.setValue( SFServiceLiveAgent.instance.getState(state: current), forKey: "label")
        CommandProcessor.processSFServiceLiveAgentstateChange(value: value)
    }
}
