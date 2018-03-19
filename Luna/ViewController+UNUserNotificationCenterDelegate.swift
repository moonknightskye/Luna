//
//  ViewController+UNUserNotificationCenterDelegate.swift
//  Luna
//
//  Created by Mart Civil on 2017/06/09.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UserNotifications

extension ViewController: UNUserNotificationCenterDelegate {

    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge])
    }
    
    // For handling tap and user actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.actionIdentifier)
        completionHandler()
    }
}
