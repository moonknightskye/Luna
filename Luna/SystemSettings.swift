//
//  SystemSettings.swift
//  Luna
//
//  Created by Mart Civil on 2017/06/16.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UIKit

class SystemSettings {
    
    static let instance:SystemSettings = SystemSettings()
    let defaults = UserDefaults.standard
    
    public init(){
        defaults.register(defaults: [String : Any]())
        defaults.synchronize()
        
        //USER SPECIFICS
        if self.get(key: "id") == nil {
            self.set(key: "id", value: "")
        }
        if self.get(key: "username") == nil {
            self.set(key: "username", value: "")
        }
        if self.get(key: "password") == nil {
            self.set(key: "password", value: "")
        }
        if self.get(key: "company") == nil {
            self.set(key: "company", value: "")
        }
        if self.get(key: "created") == nil {
            self.set(key: "created", value: "")
        }
        if self.get(key: "lastlogin") == nil {
            self.set(key: "lastlogin", value: "")
        }
        if self.get(key: "isactivated") == nil {
            self.set(key: "isactivated", value: false)
        }
        
        //DEVICE SPECIFIC
        if self.get(key: "mobile_locale") == nil {
            self.set(key: "mobile_locale", value: Locale.current.description)
        }
        if self.get(key: "mobile_added_date") == nil {
            self.set(key: "mobile_added_date", value: "")
        }
        self.set(key: "mobile_access_date", value: Date.init().description)
        
        if self.get(key: "mobile_gps") == nil {
            self.set(key: "mobile_gps", value: "")
        }
        if self.get(key: "mobile_model") == nil {
            self.set(key: "mobile_model", value: UIDevice.current.modelName)
        }
        if self.get(key: "mobile_uuid") == nil {
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                self.set(key: "mobile_uuid", value: uuid)
            }
        }
        if self.get(key: "mobile_token") == nil {
            self.set(key: "mobile_token", value: "")
        }
    }
    
    func getSystemSettings() -> NSDictionary {
        let settings = NSMutableDictionary();
        for (key, value) in defaults.dictionaryRepresentation() {
            if let vkey = key.indexOf(target: "system_") {
                settings.setValue(value, forKey: key.substring(from: vkey+7))
//                delete(key: key.substring(from: vkey+7), onSuccess: { (ddd) in}, onFail: { (ddd) in})
            }
        }
        return settings
    }
    
    public func isLoggedIn() -> Bool {
        if let loggedIn = get(key: "username") as? String {
            if !loggedIn.isEmpty {
                return true
            }
        }
        return false
    }
    
    public func get( key:String ) -> Any? {
        return defaults.object( forKey: "system_" + key )
    }
    
    public func set( key:String, value:Any ) {
        defaults.set(value, forKey: "system_" + key )
    }
//    public func delete( key:String, onSuccess: ((Bool)->()), onFail: ((String)->()) ) {
//        if self.get(key:key) != nil {
//            defaults.removeObject(forKey: "system_" + key)
//            onSuccess(true)
//        } else {
//            onFail(FileError.INEXISTENT.localizedDescription)
//        }
//    }
//    public func add( key:String, value: Any, onSuccess: ((Bool)->()), onFail: ((String)->()) ) {
//        if self.get( key: key ) == nil {
//            defaults.set(value, forKey: key)
//            onSuccess(true)
//        } else {
//            onFail(FileError.ALREADY_EXISTS.localizedDescription)
//        }
//    }

}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
