//
//  NSDate+ISO8601.swift
//  Quicksend
//
//  Created by Łukasz Adamczak on 21.09.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Foundation

extension NSDate {
    func iso8601timestamp() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        df.timeZone = NSTimeZone(name: "UTC")
        return df.stringFromDate(self)
    }

    func iso8601datestamp() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "yyyyMMdd"
        df.timeZone = NSTimeZone(name: "UTC")
        return df.stringFromDate(self)
    }
}
