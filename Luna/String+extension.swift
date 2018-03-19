//
//  String+extension.swift
//  Luna
//
//  Created by Mart Civil on 2017/02/16.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import Photos

extension String {
    
    var length:Int {
        return self.count
    }
    
    func charAt(at: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: at)
        return self[charIndex]
    }
    
    func indexOf(target: String) -> Int? {
        let range = (self as NSString).range(of: target)
        guard Range(range) != nil else {
            return nil
        }
        return range.location
    }
    
    func lastIndexOf(target: String) -> Int? {
        let range = (self as NSString).range(of: target, options: NSString.CompareOptions.backwards)
        guard Range(range) != nil else {
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
            guard start < self.length else {
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
        if let end = to, end >= 0, end < self.length {
            endIndex = self.index(self.startIndex, offsetBy: end)
        } else {
            endIndex = self.endIndex
        }
        return String(self[startIndex ..< endIndex])
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
    
    func startsWith( string:String ) -> Bool {
        return self.hasPrefix(string)
    }
    
    func endsWith( string:String ) -> Bool {
        return self.hasSuffix(string)
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
    
    func toBool() -> Bool {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return false
        }
    }
    
    func getFilenameFromFilePath() -> String? {
        var string = self
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
    
    func isValidURL() -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && self.length > 0) else { return false }
        if detector!.numberOfMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.length)) > 0 {
            return true
        }
        return false
    }

}
