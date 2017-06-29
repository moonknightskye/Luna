//
//  NSMutableData+extension.swift
//  Luna
//
//  Created by Mart Civil on 2017/06/23.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
