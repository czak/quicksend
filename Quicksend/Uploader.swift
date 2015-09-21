//
//  Uploader.swift
//  Quicksend
//
//  Created by Łukasz Adamczak on 19.07.2015.
//  Copyright (c) 2015 Łukasz Adamczak. All rights reserved.
//

import Foundation
import Alamofire

class Uploader {
    enum UploadStatus {
        case Success(NSURL)
        case Failure(String)
    }
    
    // Zmienne konfiguracyjne AWSa
    var awsAccessKeyId: String! {
        return NSUserDefaults.standardUserDefaults().stringForKey("awsAccessKeyId")
    }

    var awsSecretAccessKey: String! {
        return NSUserDefaults.standardUserDefaults().stringForKey("awsSecretAccessKey")
    }
    
    var awsBucketName: String! {
        return NSUserDefaults.standardUserDefaults().stringForKey("awsBucketName")
    }
    
    var awsRegion: String! {
        return NSUserDefaults.standardUserDefaults().stringForKey("awsRegion")
    }

    func mimetypeForFile(url: NSURL) -> String {
        let ext = url.pathExtension
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext!, nil)!.takeRetainedValue()
        if let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimeType as String
        }
        else {
            return "binary/octet-stream"
        }
    }
    
    func sizeForFile(url: NSURL) -> Int {
        let manager = NSFileManager.defaultManager()
        let attrs = try! manager.attributesOfItemAtPath(url.path!)
        return attrs[NSFileSize] as! Int
    }
    
    func uploadFile(fileURL: NSURL, completionHandler: (UploadStatus) -> Void) {
        guard (awsAccessKeyId != nil && awsSecretAccessKey != nil && awsBucketName != nil && awsRegion != nil) else {
            completionHandler(.Failure("Your AWS account has not been configured. Open Quicksend preferences to set up your connection details."))
            return
        }
        
        // 1. Canonical request
        let fileName = fileURL.lastPathComponent!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
        let fileData = NSData(contentsOfURL: fileURL)!
        let fileHash = sha256_hexdigest(fileData)
        let date = NSDate()
        let mimetype = mimetypeForFile(fileURL)
        
        let creq = "PUT\n/\(fileName)\n\ncontent-type:\(mimetype)\nhost:\(awsBucketName).s3.amazonaws.com\nx-amz-acl:public-read\nx-amz-content-sha256:\(fileHash)\nx-amz-date:\(date.iso8601timestamp())\n\ncontent-type;host;x-amz-acl;x-amz-content-sha256;x-amz-date\n\(fileHash)"
        
        debugPrint("--- CREQ ---")
        print(creq)
        print("------------")

        // 2. String to sign
        let creqHash = sha256_hexdigest(creq.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let sts = "AWS4-HMAC-SHA256\n\(date.iso8601timestamp())\n\(date.iso8601datestamp())/\(awsRegion)/s3/aws4_request\n\(creqHash)"
        
        print("--- STS ---")
        print(sts)
        print("-----------")
        
        // 3. Signing key
        
        let signingKey = awsSigningKey(key: awsSecretAccessKey,
            date: date.iso8601datestamp(),
            region: awsRegion,
            service: "s3")
        
        print(signingKey)
        
        // 4. Sygnatura
        
        let signature = hmac_sha256_hexdigest(key: signingKey, data: sts.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        print(signature)
        
        // 5. Wykonanie requestu
        
        let headers = [
            "Authorization": "AWS4-HMAC-SHA256 Credential=\(awsAccessKeyId)/\(date.iso8601datestamp())/\(awsRegion)/s3/aws4_request, SignedHeaders=content-type;host;x-amz-acl;x-amz-content-sha256;x-amz-date, Signature=\(signature)",
            "Content-Type": mimetype,
            "x-amz-acl": "public-read",
            "x-amz-content-sha256": fileHash,
            "x-amz-date": date.iso8601timestamp()
        ]
        
        let request = Alamofire.upload(.PUT, "https://\(awsBucketName).s3.amazonaws.com/\(fileName)", headers: headers, file: fileURL)
        request.response { request, response, data, error in
            var status: UploadStatus?

            if let response = response {
                switch response.statusCode {
                case 200:
                    status = .Success(response.URL!)
                case 403:
                    var message: String = "AWS Authentication failed. Please double-check your access keys and bucket data."
                    
                    if let doc = try? NSXMLDocument(data: data!, options: 0) {
                        if let node = try? doc.nodesForXPath("//Message") {
                            if let awsMessage = node.first?.stringValue {
                                message += "\n\nError message received: \"\(awsMessage)\""
                            }
                        }
                    }
                    
                    status = .Failure(message)
                    
                default:
                    var message: String = "Failed with status \(response.statusCode)"
                    
                    // FIXME: Brzydka duplikacja tego parsowania errora
                    if let doc = try? NSXMLDocument(data: data!, options: 0) {
                        if let node = try? doc.nodesForXPath("//Message") {
                            if let awsMessage = node.first?.stringValue {
                                message += "\n\nError message received: \"\(awsMessage)\""
                            }
                        }
                    }
                    
                    status = .Failure(message)
                }
            }
            else {
                status = .Failure("Unable to reach the S3 server. Please verify your internet connection.")
            }
            
            completionHandler(status!)
        }
    }
}