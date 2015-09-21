//
//  SHA256.swift
//  Quicksend
//
//  Created by Łukasz Adamczak on 21.09.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Foundation

// SHA-256 digest as a hex string
func sha256_hexdigest(data : NSData) -> String {
    // Wygenerowanie przez CommonCrypto
    var bytes = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
    CC_SHA256(data.bytes, CC_LONG(data.length), &bytes)

    // String szesnastkowy na bazie tablicy
    let hash = NSMutableString()
    for byte in bytes {
        hash.appendFormat("%02x", byte)
    }
    
    return hash as String
}

// HMAC-SHA256 mac
func hmac_sha256(key key: NSData, data: NSData) -> NSData {
    var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key.bytes, key.length, data.bytes, data.length, &hash)
    return NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
}

func hmac_sha256_hexdigest(key key: NSData, data: NSData) -> String {
    var bytes = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key.bytes, key.length, data.bytes, data.length, &bytes)
    
    // String szesnastkowy na bazie tablicy
    let hash = NSMutableString()
    for byte in bytes {
        hash.appendFormat("%02x", byte)
    }
    
    return hash as String
}