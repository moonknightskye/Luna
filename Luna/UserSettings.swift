//
//  UserDefaults.swift
//  Luna
//
//  Created by Mart Civil on 2017/05/16.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//
// https://www.hackingwithswift.com/read/12/2/reading-and-writing-basics-userdefaults

import Foundation

class UserSettings {
    
    static let instance:UserSettings = UserSettings()
    let defaults = UserDefaults.standard
    
    public init(){
        defaults.register(defaults: [String : Any]())
        defaults.synchronize()
        
        //set default values from here
        if self.get(key: "splash_screen") == nil {
            //self.defaults.set(true, forKey: "user_splash_screen")
            self.set(key: "splash_screen", value: true)
        }
        if self.get(key: "show_settings") == nil {
            //self.defaults.set(true, forKey: "user_splash_screen")
            self.set(key: "show_settings", value: "Shake 3 times or greater")
        }
        if self.get(key: "startup_type") == nil {
            self.set(key: "startup_type", value: "URL")
            //self.defaults.set("URL", forKey: "user_startup_type")
        }
        if self.get(key: "startup_page") == nil {
            self.set(key: "startup_page", value: "https://www.your_site_here.com")
            //self.defaults.set("https://www.your_site_here.com", forKey: "user_startup_page")
        }
        if self.get(key: "startup_enabled") == nil {
            self.set(key: "startup_enabled", value: false)
            //self.defaults.set(false, forKey: "user_startup_enabled")
        }
    }
    
    func getUserSettings() -> NSDictionary {
        let settings = NSMutableDictionary();
        for (key, value) in defaults.dictionaryRepresentation() {
            if let vkey = key.indexOf(target: "user_") {
                settings.setValue(value, forKey: key.substring(from: vkey+5))
            }
        }
        return settings
    }
    
    func isShowSplashScreen() -> Bool {
        return self.get(key: "splash_screen") as! Bool
    }
    func setShowSplashScreen( show:Bool ) {
        self.set(key: "splash_screen", value: show)
    }
    
    func getShowSettingsOn() -> String {
        return self.get(key: "show_settings") as! String
    }
    func setShowSettingsOn( gesture:String ) {
        self.set(key: "show_settings", value: gesture)
    }
    
    func isEnabled() -> Bool {
        return self.get(key: "startup_enabled") as! Bool
    }
    func setStartupEnabled( enabled:Bool ) {
        self.set(key: "startup_enabled", value: enabled)
    }
    
    func setStartupPage( fileName: String ) {
        self.set(key: "startup_page", value: fileName)
    }
    func getStartupPage() -> String? {
        return self.get(key: "startup_page") as? String
    }
    
    func getPathType() -> FilePathType {
        return FilePathType(rawValue: (get(key:"startup_type") as! String).lowercased())!
    }
    func setPathType( pathType:String ) {
        if let ptype = FilePathType(rawValue: pathType) {
            self.set(key: "startup_type", value: ptype.rawValue)
        }
    }
    
    func getStartupHtmlFile() -> HtmlFile? {
        if !self.isEnabled() {
            return SettingsPage.instance.getPage()
        }
        
        switch self.getPathType() {
        case .DOCUMENT_TYPE:
            if var fileName = self.getStartupPage() {
                var path = ""
                if let slashIndex = fileName.lastIndexOf(target: "/") {
                    path = fileName.substring(to: slashIndex)
                    fileName = fileName.substring(from: slashIndex + 1)
                }
                
                do {
                    return try HtmlFile(
                        fileId: File.generateID(),
                        document: fileName,
                        path: path)
                } catch {}
            }
            break
        case .URL_TYPE:
            if let urlPath = self.getStartupPage() {
                do {
                    return try HtmlFile(fileId: File.generateID(), url: urlPath)
                } catch {}
            }
            break
        default:
            break
        }
        return nil
    }
    
    public func get( key:String ) -> Any? {
        return defaults.object( forKey: "user_" + key )
    }
    
    public func set( key:String, value:Any ) {
        defaults.set(value, forKey: "user_" + key )
    }
    public func delete( key:String, onSuccess: ((Bool)->()), onFail: ((String)->()) ) {
        if self.get(key:key) != nil {
            defaults.removeObject(forKey: "user_" + key)
            onSuccess(true)
        } else {
            onFail(FileError.INEXISTENT.localizedDescription)
        }
    }
    public func add( key:String, value: Any, onSuccess: ((Bool)->()), onFail: ((String)->()) ) {
        if self.get( key: key ) == nil {
            defaults.set(value, forKey: key)
            onSuccess(true)
        } else {
            onFail(FileError.ALREADY_EXISTS.localizedDescription)
        }
    }
}
