//
//  SystemSounds.swift
//  Luna
//
//  Created by Mart Civil on 2018/02/15.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation
import AudioToolbox

class SystemSounds {
    
    static let instance:SystemSounds = SystemSounds()
    
    public func play( soundID:SystemSoundID, onSuccess:@escaping ((Bool)->()), onFail: ((String)->()) ) {
        AudioServicesPlaySystemSoundWithCompletion(soundID) {
            AudioServicesDisposeSystemSoundID(soundID)
            onSuccess(true)
        }
        AudioServicesPlaySystemSound(soundID)
    }
}
