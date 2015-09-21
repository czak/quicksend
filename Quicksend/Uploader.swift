//
//  Uploader.swift
//  Quicksend
//
//  Created by Łukasz Adamczak on 19.07.2015.
//  Copyright (c) 2015 Łukasz Adamczak. All rights reserved.
//

import Foundation
import Alamofire

let AWSAccessKeyID = "AKIAJFGBQKHT7H53DOYQ"
let AWSSecretAccessKey = "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"
let AWSBucketName = "czak-screenshots"
let AWSRegion = "eu-west-1"

class Uploader {
    enum UploadStatus {
        case Success(String)
        case Failure(String)
    }
    
    let serverURL: String
    
    init(serverURL: String) {
        self.serverURL = serverURL
    }
    
    func mimetypeForFile(url: NSURL) -> String {
        let ext = url.pathExtension
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext!, nil)!.takeRetainedValue()
        let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)!.takeRetainedValue()
        return mimeType as String
    }
    
    func sizeForFile(url: NSURL) -> Int {
        let manager = NSFileManager.defaultManager()
        let attrs = try! manager.attributesOfItemAtPath(url.path!)
        return attrs[NSFileSize] as! Int
    }
    
    func uploadFile(fileURL: NSURL, completionHandler: (UploadStatus) -> Void) {
        // 1. Canonical request
        let fileName = fileURL.lastPathComponent!
        let fileData = NSData(contentsOfURL: fileURL)!
        let fileHash = sha256_hexdigest(fileData)
        let date = NSDate()
        let mimetype = mimetypeForFile(fileURL)
        
        let creq = "PUT\n/\(fileName)\n\ncontent-type:\(mimetype)\nhost:\(AWSBucketName).s3.amazonaws.com\nx-amz-acl:public-read\nx-amz-content-sha256:\(fileHash)\nx-amz-date:\(date.iso8601timestamp())\n\ncontent-type;host;x-amz-acl;x-amz-content-sha256;x-amz-date\n\(fileHash)"
        
        debugPrint("--- CREQ ---")
        print(creq)
        print("------------")

        // 2. String to sign
        let creqHash = sha256_hexdigest(creq.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let sts = "AWS4-HMAC-SHA256\n\(date.iso8601timestamp())\n\(date.iso8601datestamp())/\(AWSRegion)/s3/aws4_request\n\(creqHash)"
        
        print("--- STS ---")
        print(sts)
        print("-----------")
        
        // 3. Signing key
        
        let signingKey = awsSigningKey(key: AWSSecretAccessKey,
            date: date.iso8601datestamp(),
            region: AWSRegion,
            service: "s3")
        
        print(signingKey)
        
        // 4. Sygnatura
        
        let signature = hmac_sha256_hexdigest(key: signingKey, data: sts.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        print(signature)
        
        let headers = [
            "Authorization": "AWS4-HMAC-SHA256 Credential=\(AWSAccessKeyID)/\(date.iso8601datestamp())/\(AWSRegion)/s3/aws4_request, SignedHeaders=content-type;host;x-amz-acl;x-amz-content-sha256;x-amz-date, Signature=\(signature)",
            "Content-Type": mimetype,
            "x-amz-acl": "public-read",
            "x-amz-content-sha256": fileHash,
            "x-amz-date": date.iso8601timestamp()
        ]
        
        let request = Alamofire.upload(.PUT, "https://\(AWSBucketName).s3.amazonaws.com/\(fileName)", headers: headers, file: fileURL)
        request.response { request, response, data, error in
            print(request)
            print(response)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            print(error)
        }
        
//        Alamofire.upload(
//            .POST,
//            serverURL,
//            multipartFormData: { multipartFormData in
//                multipartFormData.appendBodyPart(fileURL: fileURL, name: "image")
//            },
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .Success(let upload, _, _):
//                    upload.responseJSON { request, response, result in
//                        var uploadStatus: UploadStatus?
//                        
//                        if let dict = result.value as? NSDictionary, link = dict["link"] as? String {
//                            uploadStatus = .Success(link)
//                        }
//                        else {
//                            uploadStatus = .Failure("No link in \(result)")
//                        }
//                        
//                        completionHandler(uploadStatus!)
//                    }
//                case .Failure(let encodingError):
//                    completionHandler(.Failure("Encoding error: \(encodingError)"))
//                }
//            }
//        )
    }
}