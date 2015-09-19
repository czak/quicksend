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
        case Success(String)
        case Failure(String)
    }
    
    let serverURL: String
    
    init(serverURL: String) {
        self.serverURL = serverURL
    }
    
    func uploadFile(fileURL: NSURL, completionHandler: (UploadStatus) -> Void) {
        let testFileURL = NSBundle.mainBundle().URLForResource("quicksend-test", withExtension: "txt")!
        let headers = [
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIAJFGBQKHT7H53DOYQ/20150919/eu-west-1/s3/aws4_request, SignedHeaders=content-type;host;x-amz-acl;x-amz-content-sha256;x-amz-date, Signature=93820258ae0ed2a8fe92b70a861abc99fd8c918da3d0f5e97414446b92359884",
            "Content-Type": "text/plain",
            "x-amz-acl": "public-read",
            "x-amz-content-sha256": "39ed0b8a89161802d213e89fc4edf9039aae42cba8dc7fb06f9204ed74a70b7e",
            "x-amz-date": "20150919T210649Z"
        ]
        
        let request = Alamofire.upload(.PUT, "https://czak-screenshots.s3.amazonaws.com/quicksend-test.txt", headers: headers, file: testFileURL)
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