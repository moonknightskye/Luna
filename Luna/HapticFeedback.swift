//
//  HapticFeedback.swift
//  Luna
//
//  Created by Mart Civil on 2018/02/03.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class HapticFeedback {
    
    static let instance:HapticFeedback = HapticFeedback()
    let selectionFeedback:UISelectionFeedbackGenerator!
    let notificationFeedback:UINotificationFeedbackGenerator!
    var impactFeedback:UIImpactFeedbackGenerator!
    
    public init(){
        selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.prepare()
        notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        impactFeedback = UIImpactFeedbackGenerator()
        impactFeedback.prepare()
    }
    
    static func supportLevel() -> Int {
        return UIDevice.current.value(forKey: "_feedbackSupportLevel") as? Int ?? 0
    }
    
    public func feedback( type:String, onSuccess: ((Bool)->()), onFail: ((String)->()) ) {
        switch type.lowercased() {
        case "error":
            if HapticFeedback.supportLevel() < 2 {
                onFail("This device doesnt support " + type + " feedback")
            } else {
                notificationFeedback.notificationOccurred(.error)
                notificationFeedback.prepare()
                onSuccess(true)
            }
            break
        case "success":
            if HapticFeedback.supportLevel() < 2 {
                onFail("This device doesnt support " + type + " feedback")
            } else {
                notificationFeedback.notificationOccurred(.success)
                notificationFeedback.prepare()
                onSuccess(true)
            }
            break
        case "warning":
            if HapticFeedback.supportLevel() < 2 {
                onFail("This device doesnt support " + type + " feedback")
            } else {
                notificationFeedback.notificationOccurred(.warning)
                notificationFeedback.prepare()
                onSuccess(true)
            }
            break
        case "light":
            if HapticFeedback.supportLevel() < 1 {
                onFail("This device doesnt support " + type + " feedback")
            } else {
                impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                impactFeedback.prepare()
                onSuccess(true)
            }
            break
        case "medium":
            if HapticFeedback.supportLevel() < 1 {
                onFail("This device doesnt support " + type + " feedback")
            } else {
                impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                impactFeedback.prepare()
                onSuccess(true)
            }
            break
        case "heavy":
            if HapticFeedback.supportLevel() < 1 {
                onFail("This device doesnt support " + type + " feedback")
            } else {
                impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                impactFeedback.prepare()
                onSuccess(true)
            }
            break
        case "select":
            if HapticFeedback.supportLevel() < 1 {
                onFail("This device doesnt support " + type + " feedback")
            } else {
                selectionFeedback.selectionChanged()
                selectionFeedback.prepare()
                onSuccess(true)
            }
            break
        case "peek":
            AudioServicesPlaySystemSound(1519)
            onSuccess(true)
            break
        case "pop":
            AudioServicesPlaySystemSound(1520)
            onSuccess(true)
            break
        case "nope":
            AudioServicesPlaySystemSound(1521)
            onSuccess(true)
            break
        case "vibrate":
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            onSuccess(true)
            break
        default:
            onFail("type " + type + " is invalid")
            break
        }
    }
}
