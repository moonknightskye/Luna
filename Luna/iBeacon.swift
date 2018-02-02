//
//  iBeacon.swift
//  Luna
//
//  Created by Mart Civil on 2018/01/11.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

class iBeacon {

    static let instance:iBeacon = iBeacon()
    private var isiBeaconScannerInit = false
    var isAccessPermitted = false
    var beaconPeripheralData: NSDictionary?
    var peripheralManager: CBPeripheralManager?
    var locationManager: CLLocationManager?
    var permissionStatus: CLAuthorizationStatus?
    var checkPermissionAction:((Bool)->())?
    
    private func initiBeaconScanner() {
        locationManager = CLLocationManager()
        locationManager?.delegate = Shared.shared.ViewController
    }
    
    func requestAuthorization( status: CLAuthorizationStatus ) {
        if status == .authorizedAlways {
            if locationManager == nil {
                initiBeaconScanner()
            }
            locationManager?.requestAlwaysAuthorization()
        } else if status == .authorizedWhenInUse {
            if locationManager == nil {
                initiBeaconScanner()
            }
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    func getBeaconRegion( from: [NSDictionary] ) -> [CLBeaconRegion] {
        var regions = [CLBeaconRegion]()
        for regiondict in from {
            if let region = getBeaconRegion( from: regiondict ) {
                regions.append(region)
            }
        }
        return regions
    }
    
    func getBeaconRegion( from: NSDictionary ) -> CLBeaconRegion? {
        if let uiid = from.value(forKeyPath: "uiid") as? String {
            let major = from.value(forKeyPath: "major") as? UInt16
            let minor = from.value(forKeyPath: "minor") as? UInt16
            let identifier = from.value(forKeyPath: "identifier") as? String ?? "com.salesforce.Luna"
            
            if( major == nil && minor == nil) {
                return CLBeaconRegion(proximityUUID: UUID(uuidString: uiid)!, identifier: identifier)
            } else if( major != nil && minor == nil ) {
                return CLBeaconRegion(proximityUUID: UUID(uuidString: uiid)!, major: major!, identifier: identifier)
            } else {
                return CLBeaconRegion(proximityUUID: UUID(uuidString: uiid)!, major: major!, minor: minor!, identifier: identifier)
            }
        }
        return nil
    }
    
    func beaconRegionToDictionary( from:CLBeaconRegion ) -> NSMutableDictionary {
        let value = NSMutableDictionary()
        value.setValue( from.proximityUUID.uuidString, forKey: "uiid")
        value.setValue( from.major, forKey: "major")
        value.setValue( from.minor, forKey: "minor")
        value.setValue( from.identifier, forKey: "identifier")
        return value
    }
    func beaconRegionToDictionary( from:CLRegion ) -> NSMutableDictionary {
        let region = from as! CLBeaconRegion
        return beaconRegionToDictionary( from:region  )
    }
    func beaconRegionToDictionary( from:Set<CLRegion> ) -> [NSMutableDictionary] {
        var values = [NSMutableDictionary]()
        for region in from {
            values.append(beaconRegionToDictionary(from: region))
        }
        return values
    }
    
    func startiBeaconMonitoringScanner( regions:[CLBeaconRegion], onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        for region in regions {
            startiBeaconMonitoringScanner(region: region)
        }
        onSuccess?(true)
    }
    func startiBeaconMonitoringScanner( region: CLBeaconRegion, onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        if locationManager == nil {
            initiBeaconScanner()
        }
        region.notifyEntryStateOnDisplay = false
        region.notifyOnExit = true
        region.notifyOnEntry = true
        locationManager?.startMonitoring(for: region)
        onSuccess?(true)
    }
    
    func startiBeaconRangingScanner( regions: [CLBeaconRegion], onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        for region in regions {
            startiBeaconRangingScanner(region: region)
        }
        onSuccess?(true)
    }
    func startiBeaconRangingScanner( region: CLBeaconRegion, onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        if locationManager == nil {
            initiBeaconScanner()
        }
        locationManager?.startRangingBeacons(in: region)
        onSuccess?(true)
    }
    
    func getAllMonitoredBeacons( onSuccess: ((NSMutableDictionary)->())?=nil, onFail: ((String)->())?=nil ) {
        if locationManager == nil {
            onFail?("iBeacon not scanning")
            return
        }
        
        let monitored = beaconRegionToDictionary(from: locationManager!.monitoredRegions )
        let ranged = beaconRegionToDictionary( from:locationManager!.rangedRegions )
        if( monitored.count <= 0 && ranged.count <= 0 ) {
            onFail?("No Monitored Beacons")
            return
        }
        let value = NSMutableDictionary()
        value.setValue(monitored, forKey: "monitor")
        value.setValue(ranged, forKey: "range")
        onSuccess?( value )
    }
    
    func stopAlliBeaconScanner( onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        if locationManager == nil {
            onFail?("iBeacon not scanning")
            return
        }
        var didStopped = false
        
        for region in locationManager!.monitoredRegions {
            stopiBeaconMonitoringScanner(region: region)
            didStopped = true
        }
        for region in locationManager!.rangedRegions {
            stopiBeaconRangingScanner( region: region as! CLBeaconRegion )
            didStopped = true
        }
        if didStopped {
            onSuccess?(true)
        } else {
            onFail?("There is no ranged or monitored beacons")
        }
    }
    
    func stopiBeaconMonitoringScanner( regions: [CLRegion], onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        for region in regions {
            stopiBeaconMonitoringScanner( region: region, onFail: onFail )
        }
        onSuccess?(true)
    }
    func stopiBeaconMonitoringScanner( region: CLRegion, onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        if locationManager == nil {
            onFail?("iBeacon not scanning")
            return
        }
        locationManager?.stopMonitoring(for: region)
        onSuccess?(true)
    }
    
    func stopiBeaconRangingScanner( regions: [CLBeaconRegion], onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        for region in regions {
            stopiBeaconRangingScanner( region: region, onFail: onFail )
        }
        onSuccess?(true)
    }
    func stopiBeaconRangingScanner( region: CLBeaconRegion, onSuccess: ((Bool)->())?=nil, onFail: ((String)->())?=nil ) {
        if locationManager == nil {
            onFail?("iBeacon not scanning")
            return
        }
        locationManager?.stopRangingBeacons(in: region)
        onSuccess?(true)
    }
    
    func transmitiBeacon( region:CLBeaconRegion, onSuccess: (NSDictionary)->(), onFail: (String)->() ) {
        if peripheralManager != nil {
            onFail("iBeacon already trasmitting")
            return
        }
        beaconPeripheralData = region.peripheralData(withMeasuredPower: -59)
        peripheralManager = CBPeripheralManager(delegate: Shared.shared.ViewController, queue: nil, options: nil)
        onSuccess( beaconRegionToDictionary(from:region ) )
    }
    
    func stopiBeacon( onSuccess: (Bool)->(), onFail: (String)->() ) {
        if peripheralManager == nil {
            onFail("iBeacon already stopped")
            return
        }
        peripheralManager?.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        
        onSuccess(true)
    }
    
}
