//
//  ViewController+ CBPeripheralManagerDelegate.swift
//  Luna
//
//  Created by Mart Civil on 2018/01/10.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

extension ViewController: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let value = NSMutableDictionary()
        var lbl:String = "Undefined"
        value.setValue( peripheral.state.rawValue, forKey: "code")
        if peripheral.state == .poweredOn {
            lbl = "PoweredOn"
            iBeacon.instance.peripheralManager?.startAdvertising(iBeacon.instance.beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .poweredOff {
            lbl = "PoweredOff"
            iBeacon.instance.peripheralManager?.stopAdvertising()
        }
        value.setValue( lbl, forKey: "label")
        CommandProcessor.processiBeaconDidUpdate(value: value)
    }
}
