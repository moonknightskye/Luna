//
//  UserDefaults.swift
//  Luna
//
//  Created by Mart Civil on 2017/05/16.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

class UserSettings {
    
    static let instance:UserSettings = UserSettings()
    
    public init(){
        UserDefaults.standard.register(defaults: [String : Any]())
        UserDefaults.standard.synchronize()
    
        print( UserDefaults.standard.string(forKey: "user_startup_enabled") ?? "user_startup_enabled")
        print( UserDefaults.standard.string(forKey: "user_startup_page") ?? "user_startup_page")
        print( UserDefaults.standard.string(forKey: "user_startup_type") ?? "user_startup_type")
        print( UserDefaults.standard.string(forKey: "user_startup_path") ?? "user_startup_path")
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
    
    func getPath() -> String? {
        return UserSettings.instance.get(key: "user_startup_path")
    }
    func setPath( path:String ) {
        UserSettings.instance.set(key: "user_startup_path", value: path)
    }
    
    func getPathType() -> FilePathType {
        print( get(key:"user_startup_type") ?? "none")
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
            if let fileName = UserSettings.instance.getFileName() {
                do {
                    return try HtmlFile(
                        fileId: File.generateID(),
                        document: fileName,
                        path: UserSettings.instance.getPath())
                } catch {}
            }
            break
        case .BUNDLE_TYPE:
            if let fileName = UserSettings.instance.getFileName() {
                do {
                    return try HtmlFile(
                        fileId: File.generateID(),
                        bundle: fileName,
                        path: UserSettings.instance.getPath())
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
        return UserDefaults.standard.bool(forKey:key)
    }
    public func get( key:String ) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    public func set( key:String, value:Any ) {
        return UserDefaults.standard.set(value, forKey: key)
    }
}
