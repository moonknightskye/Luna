//
//  String+extension.swift
//  Luna
//
//  Created by Mart Civil on 2017/02/16.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

extension String {
    
    var length:Int {
        return self.characters.count
    }
    
    func indexOf(target: String) -> Int? {
        let range = (self as NSString).range(of: target)
        guard range.toRange() != nil else {
            return nil
        }
        return range.location
    }
    
    func lastIndexOf(target: String) -> Int? {
        let range = (self as NSString).range(of: target, options: NSString.CompareOptions.backwards)
        guard range.toRange() != nil else {
            return nil
        }
        return range.location
        //return self.length - range.location - 1
    }
    
    func contains(s: String) -> Bool {
        return (self.range(of: s) != nil) ? true : false
    }
    
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.characters.count else {
                return ""
            }
        }
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.characters.count {
            endIndex = self.index(self.startIndex, offsetBy: end)
        } else {
            endIndex = self.endIndex
        }
        return self[startIndex ..< endIndex]
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        return self.substring(from: start, to: to)
    }
    
    func getFilenameFromURL() -> String? {
        var string = self
        if self.isValidURL() {
            if let ampersand = self.indexOf(target: "#") {
                string = string.substring(from: 0, to: ampersand)
            } else {
                string = string.substring(from: 0, to: string.length)
            }
            
            if let question = string.indexOf(target: "?") {
                string = string.substring(from: 0, to: question)
            } else {
                string = string.substring(from: 0, to: string.length)
            }
            
            return string.substring( from:string.lastIndexOf(target: "/")! + 1, to:string.length );
        }
        return nil
    }
    
    func isValidURL() -> Bool {
        if let url  = URL(string: self) {
            return Shared.shared.UIApplication.canOpenURL( url )
        }
        return false
    }

}
