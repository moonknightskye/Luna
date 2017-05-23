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
        if self.defaults.string(forKey: "user_startup_type") == nil {
            self.defaults.set("URL", forKey: "user_startup_type")
        }
        if self.defaults.string(forKey: "user_startup_page") == nil {
            self.defaults.set("https://www.your_site_here.com", forKey: "user_startup_page")
        }
        if self.defaults.string(forKey: "user_startup_enabled") == nil {
            self.defaults.set(false, forKey: "user_startup_enabled")
        }
        
        for (key, value) in defaults.dictionaryRepresentation() {
            print("\(key) = \(value) \n")
        }
    }
    
    func isEnabled() -> Bool {
        return UserSettings.instance.get(key: "user_startup_enabled")
    }
    func setStartupEnabled( enabled:Bool ) {
        UserSettings.instance.set(key: "user_startup_enabled", value: enabled)
    }
    
    func setFileName( fileName: String ) {
        UserSettings.instance.set(key: "user_startup_page", value: fileName)
    }
    func getFileName() -> String? {
        return UserSettings.instance.get(key: "user_startup_page")
    }
    
    func getPathType() -> FilePathType {
        return FilePathType(rawValue: get(key:"user_startup_type")!.lowercased())!
    }
    func setPathType( pathType:String ) {
        if let ptype = FilePathType(rawValue: pathType) {
            UserSettings.instance.set(key: "user_startup_type", value: ptype.rawValue)
        }
    }
    
    func getStartupHtmlFile() -> HtmlFile? {
        switch UserSettings.instance.getPathType() {
        case .DOCUMENT_TYPE:
            if var fileName = UserSettings.instance.getFileName() {
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
            if let urlPath = UserSettings.instance.getFileName() {
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
    
    public func get( key:String ) -> Bool {
        return defaults.bool(forKey:key)
    }
    public func get( key:String ) -> String? {
        return defaults.string(forKey: key)
    }
    public func set( key:String, value:Any ) {
        return UserDefaults.standard.set(value, forKey: key)
    }
}
