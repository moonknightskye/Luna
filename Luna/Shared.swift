//
//  Shared.swift
//  Salesforce Hybrid
//
//  Created by Mart Civil on 2016/12/27.
//  Copyright © 2016年 salesforce.com. All rights reserved.
//

import UIKit
import CoreMotion

final class Shared: NSObject {
    static let shared = Shared() //lazy init, and it only runs once
    
    var UIApplication:UIApplication!
    var ViewController:ViewController!
    var DeviceID = UIDevice.current.identifierForVendor!.uuidString
	var iCloudAvailable = false
	var allowsCellularAccess = true

}
