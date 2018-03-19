//
//  LOcation.swift
//  Luna
//
//  Created by Mart Civil on 2018/03/14.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    static let instance:Location = Location()
    var isAccessPermitted = false
    var locationManager: CLLocationManager!
    var checkPermissionAction:((Bool)->())?
    
    init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = Shared.shared.ViewController
    }
    
    func requestAuthorization( status: CLAuthorizationStatus ) {
        if status == .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func stopLocationTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func startLocationTracking() {
        locationManager.startUpdatingLocation()
    }
}
