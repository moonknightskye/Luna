//
//  UserNotification.swift
//  Luna
//
//  Created by Mart Civil on 2017/06/09.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UserNotifications

class UserNotification {
    static let instance:UserNotification = UserNotification()
    
    init() {}
    
    func requestAuthorization(isPermitted:@escaping ((Bool)->())) {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
                UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
                    if error != nil {
                        isPermitted(false)
                        return
                    }
                    
                    if granted {
                        DispatchQueue.main.async {
                            Shared.shared.UIApplication.registerForRemoteNotifications()
                        }
                        UNUserNotificationCenter.current().delegate = Shared.shared.ViewController
                        isPermitted(true)
                    } else {
                        isPermitted(false)
                    }
                }
                
            }
            
            if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
                isPermitted(false)
            }
            
            if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
                DispatchQueue.main.async {
                    Shared.shared.UIApplication.registerForRemoteNotifications()
                }
                UNUserNotificationCenter.current().delegate = Shared.shared.ViewController
                isPermitted(true)
            }
        })
    }
}
