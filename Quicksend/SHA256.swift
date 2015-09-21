//
//  SHA256.swift
//  Quicksend
//
//  Created by Łukasz Adamczak on 21.09.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Foundation

// SHA-256 digest
func sha256(data : NSData) -> NSData {
    var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
    CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
    return NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
}

// HMAC-SHA256 mac
func hmac_sha256(key key: NSData, data: NSData) -> NSData {
    var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key.bytes, key.length, data.bytes, data.length, &hash)
    return NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
}