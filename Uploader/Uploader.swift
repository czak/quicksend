//
//  Uploader.swift
//  Uploader
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
    
    class func uploadFile(fileURL: NSURL, completionHandler: (UploadStatus) -> Void) {
        Alamofire.upload(
            .POST,
            URLString: "http://localhost:8080/upload/",
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: fileURL, name: "image")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { request, response, JSON, error in
                        var uploadStatus: UploadStatus?
                        
                        if let dict = JSON as? NSDictionary, link = dict["link"] as? String {
                            uploadStatus = .Success(link)
                        }
                        else {
                            uploadStatus = .Failure("No link in \(JSON)")
                        }
                        
                        completionHandler(uploadStatus!)
                    }
                case .Failure(let encodingError):
                    completionHandler(.Failure("Encoding error: \(encodingError)"))
                }
            }
        )
    }
}