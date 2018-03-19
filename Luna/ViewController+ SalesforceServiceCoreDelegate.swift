//
//  ViewController+UNUserNotificationCenterDelegate.swift
//  Luna
//
//  Created by Mart Civil on 2017/06/09.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import UIKit
import ServiceCore
import ServiceSOS

extension ViewController: SOSDelegate {
    
    /**
     *  Tells the delegate that an SOS session is stopping.
     *
     *  This event is invoked when the session is entering its cleanup phase.
     *
     *  @param sos    `SOSSessionManager` instance that invoked the delegate method.
     *  @param reason `SOSStopReason` enum for why the session ended.
     *  @param error  `NSError` instance returned if the session ended as the result of an error.
     *                Compare the error code to `SOSErrorCode` for details about the error.
     *                Error is `nil` if the session ended cleanly.
     *  @see `SOSSessionManager`
     *  @see `SOSStopReason`
     *  @see `SOSErrorCode`
     */
    func sos(_ sos: SOSSessionManager!, didStopWith reason: SOSStopReason, error: Error!) {
        var code = 0
        var label = ""
        if (error != nil) {
            code = (error as NSError).code
            label = error.localizedDescription
        } else {
            code = reason.rawValue
            label = SFServiceSOS.instance.getErrorLabel(reason: reason)
        }
        
        let value = NSMutableDictionary()
        value.setValue( code, forKey: "code")
        value.setValue( label, forKey: "label")
        CommandProcessor.processSFServiceSOSdidStop( value: value )
    }
    
    /**
     *  Calls the delegate when the SOS session has connected. The session is now fully active.
     *
     *  @param sos `SOSSessionManager` instance that invoked the delegate method.
     *  @see `SOSSessionManager`
     */
    func sosDidConnect(_ sos: SOSSessionManager!) {
        CommandProcessor.processSFServiceSOSdidConnect()
    }
    
    /**
     *  Tells the delegate that the SOS state changed.
     *
     *  @param sos      `SOSSessionManager` instance that executed the delegate.
     *  @param current  The new `SOSSessionState` that has been set on the `SOSSessionManager` instance.
     *  @param previous The previous `SOSSessionState`.
     *  @see `SOSSessionManager`
     *  @see `SOSSessionState`
     */
    func sos(_ sos: SOSSessionManager!, stateDidChange current: SOSSessionState, previous: SOSSessionState) {
        let value = NSMutableDictionary()
        value.setValue( current.rawValue, forKey: "code")
        value.setValue( SFServiceSOS.instance.getState(state: current), forKey: "label")
        CommandProcessor.processSFServiceSOSstateChange(value: value)
    }
}

