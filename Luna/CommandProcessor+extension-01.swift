//
//  CommandProcessor+extension-01.swift
//  Luna
//
//  Created by Mart Civil on 2017/05/25.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

extension CommandProcessor {
    
//    public class func checkUserSettingsAdd( command: Command ) {
//        checkUserSettingsAdd( command: command, onSuccess: { result in
//            command.resolve( value: result )
//        }, onFail: { errorMessage in
//            command.reject( errorMessage: errorMessage )
//        })
//    }
//    private class func checkUserSettingsAdd( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
//        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String,
//            let value = (command.getParameter() as AnyObject).value(forKeyPath: "value") as Any? {
//            UserSettings.instance.add(key: key, value: value, onSuccess:onSuccess, onFail:onFail)
//        } else {
//            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
//        }
//    }
    
    public class func checkUserSettingsDelete( command: Command ) {
        checkUserSettingsDelete( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsDelete( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String {
            UserSettings.instance.delete(key: key, onSuccess:onSuccess, onFail:onFail)
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
        }
    }
    
    public class func checkUserSettingsGet( command: Command ) {
        checkUserSettingsGet( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsGet( command: Command, onSuccess: @escaping((Any)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String {
            if let value = UserSettings.instance.get(key: key) {
                onSuccess( value )
                return
            }
        }
        onFail( FileError.INVALID_PARAMETERS.localizedDescription )
    }
    
    public class func checkUserSettingsSet( command: Command ) {
        checkUserSettingsSet( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsSet( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String,
            let value = (command.getParameter() as AnyObject).value(forKeyPath: "value") as Any? {
            UserSettings.instance.set(key: key, value: value)
            onSuccess( true )
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
        }
    }
    
    @objc public class func test(){
        print("hello")
    }

}
