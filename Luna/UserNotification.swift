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
    
    func checkAccess(onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->())) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
            if error != nil {
                onFail(error!.localizedDescription)
                return
            }
            
            if granted {
                onSuccess( true )
            } else {
                onFail("User revoked access to Notifications")
            }
        }
        
        UNUserNotificationCenter.current().delegate = Shared.shared.ViewController
    }
    
}
