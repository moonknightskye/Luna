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
        
        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.
        
        completionHandler([.alert,.badge])
    }
    
    // For handling tap and user actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "option1":
            print("Action First Tapped x ")
        case "option2":
            print("Action Second Tapped xx")
        case "option3":
            print("Action Third Tapped xxxx")
        default:
            break
        }
        completionHandler()
    }
}
