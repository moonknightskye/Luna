//
//  ViewController+ CLLocationManagerDelegate.swift
//  Luna
//
//  Created by Mart Civil on 2018/01/10.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation
import CoreLocation

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let beaconRegion = region as! CLBeaconRegion

        let value = NSMutableDictionary()
        value.setValue( beaconRegion.proximityUUID.uuidString, forKey: "uiid")
        value.setValue( beaconRegion.major, forKey: "major")
        value.setValue( beaconRegion.minor, forKey: "minor")
        value.setValue( beaconRegion.identifier, forKey: "identifier")
        
        var stateLbel = ""
        switch (state) {
        case .inside:
            stateLbel = "inside"
            break;
        case .outside:
            stateLbel = "outside"
            break;
        case .unknown:
            stateLbel = "unknown"
            break;
        }
        let stateDict = NSMutableDictionary()
        stateDict.setValue( state.rawValue, forKey: "code")
        stateDict.setValue( stateLbel, forKey: "label")
        value.setValue( stateDict, forKey: "state")
        print("STATE " + beaconRegion.proximityUUID.uuidString, state.rawValue)
        CommandProcessor.processiBeaconOnMonitor(value: value)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.isRangingAvailable() {
                if status == .authorizedAlways || status == .authorizedWhenInUse {
                    iBeacon.instance.checkPermissionAction?(true)
                } else if status == .denied || status == .restricted {
                    iBeacon.instance.checkPermissionAction?(false)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            let value = NSMutableDictionary()
            value.setValue( region.proximityUUID.uuidString, forKey: "uiid")
            value.setValue( region.major, forKey: "major")
            value.setValue( region.minor, forKey: "minor")
            value.setValue( region.identifier, forKey: "identifier")
            let range = NSMutableDictionary()
            var proximityLbel = ""
            switch( beacon.proximity ) {
            case .immediate:
                proximityLbel = "immediate"
                break;
            case .near:
                proximityLbel = "near"
                break;
            case .far:
                proximityLbel = "far"
                break;
            case .unknown:
                proximityLbel = "unknown"
                break;
            }
            range.setValue( beacon.accuracy, forKey: "accuracy")
            range.setValue( beacon.proximity.rawValue, forKey: "code")
            range.setValue( proximityLbel, forKey: "label")
            value.setValue( range, forKey: "proximity")
            CommandProcessor.processiBeaconOnRange(value: value)
        }
    }
}
