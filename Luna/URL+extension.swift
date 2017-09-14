//
//  URL.swift
//  SosForFsl
//
//  Created by Hiroki Tanaka on 7/25/17.
//  Copyright © 2017 Hiroki Tanaka. All rights reserved.
//

import Foundation

extension URL {
    public var queryItems: [String: String] {
        var params = [String: String]()
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems?.reduce([:], { (_, item) -> [String: String] in
                params[item.name] = item.value
                return params
            }) ?? [:]
    }
}
