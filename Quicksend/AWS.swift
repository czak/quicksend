//
//  AWS.swift
//  Quicksend
//
//  Created by Łukasz Adamczak on 21.09.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Foundation

func awsSigningKey(key key: String, date: String, region: String, service: String) -> NSData {
    let dateKey = hmac_sha256(key: "AWS4\(key)".dataUsingEncoding(NSUTF8StringEncoding)!, data: date.dataUsingEncoding(NSUTF8StringEncoding)!)
    let dateRegionKey = hmac_sha256(key: dateKey, data: region.dataUsingEncoding(NSUTF8StringEncoding)!)
    let dateRegionServiceKey = hmac_sha256(key: dateRegionKey, data: service.dataUsingEncoding(NSUTF8StringEncoding)!)
    let signingKey = hmac_sha256(key: dateRegionServiceKey, data: "aws4_request".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    return signingKey
}
