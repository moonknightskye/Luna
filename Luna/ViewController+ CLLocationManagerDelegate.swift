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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            Location.instance.isAccessPermitted = true
            Location.instance.checkPermissionAction?(true)
        } else if status == .denied || status == .restricted {
            Location.instance.isAccessPermitted = false
            Location.instance.checkPermissionAction?(false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Location.instance.stopLocationTracking()
        let userLocation:CLLocation = locations[0] as CLLocation
        SystemSettings.instance.set(key: "mobile_gps", value: "(" + String(userLocation.coordinate.latitude) + "," + String(userLocation.coordinate.longitude) + ")")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
}
