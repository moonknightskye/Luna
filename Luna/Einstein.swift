//
//  EinsteinVision.swift
//  Luna
//
//  Created by Mart Civil on 2018/03/06.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation
class EinsteinAuth {
    static let instance:EinsteinAuth = EinsteinAuth()

    var TOKEN:String?;
    
    func getToken(accountId:String?=nil, privateKey:String?=nil, isRequestNew:Bool?=false, onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->())) {
        if( TOKEN != nil && !isRequestNew! ) {
            onSuccess( TOKEN! )
            return
        }
        
        var parameter = [String: Any]()
        parameter[ "url" ] = "https://luna-vision.herokuapp.com/tokenize"
        parameter[ "method" ] = "POST"
        
        var headers = [String: String]()
        headers[ "Content-Type" ] = "application/json"
        parameter[ "headers" ] = headers
        
        var data = [String: Any]()
        data[ "privateKey" ] = privateKey
        data[ "accountId" ] = accountId
        data[ "isRequestNew" ] = isRequestNew
        parameter[ "data" ] = data
        
        let httpPost = Command( commandCode: CommandCode.HTTP_POST, parameter: parameter as NSDictionary)
        httpPost.onResolve(fn: { (token) in
            guard let token = token as? NSDictionary, let accesstoken = token.value(forKey: "access_token") as? String else {
                onFail("No access_token returned")
                return
            }
            self.TOKEN = accesstoken
            onSuccess( accesstoken )
        })
        httpPost.onReject(fn: { (errorMessage) in
            onFail(errorMessage)
        })
        CommandProcessor.queue(command: httpPost)
    }
}

class EinsteinLanguage {
    
    static let instance:EinsteinLanguage = EinsteinLanguage()
    let SENTIMENT_MODEL_ID   = "CommunitySentiment"
    let INTENT_MODEL_ID      = "N3WZHTPDXNXCED6VOPHAUNDSLQ"
    
    func sentiment( token:String, modelId:String?=nil, text:String, onSuccess:@escaping ((NSDictionary)->()), onFail:@escaping ((String)->())) {
        var parameter = [String: Any]()
        parameter[ "url" ] = "https://api.einstein.ai/v2/language/sentiment"
        parameter[ "method" ] = "POST"
        
        var headers = [String: String]()
        headers[ "Authorization" ] = "Bearer " + token
        headers[ "Cache-Control" ] = "no-cache"
        parameter[ "headers" ] = headers
        
        var multipart = [String: String]()
        multipart[ "modelId" ] = modelId ?? SENTIMENT_MODEL_ID
        multipart[ "document" ] = text
        parameter[ "multipart" ] = multipart
        
        let httpPost = Command( commandCode: CommandCode.HTTP_POST, parameter: parameter as NSDictionary)
        httpPost.onResolve(fn: { (result) in
            guard let result = result as? NSDictionary else {
                onFail("No results returned")
                return
            }
            onSuccess( result )
        })
        httpPost.onReject(fn: onFail)
        CommandProcessor.queue(command: httpPost)
    }
    
    func intent( token:String, modelId:String?=nil, text:String, onSuccess:@escaping ((NSDictionary)->()), onFail:@escaping ((String)->())) {
        var parameter = [String: Any]()
        parameter[ "url" ] = "https://api.einstein.ai/v2/language/intent"
        parameter[ "method" ] = "POST"
        
        var headers = [String: String]()
        headers[ "Authorization" ] = "Bearer " + token
        headers[ "Cache-Control" ] = "no-cache"
        parameter[ "headers" ] = headers
        
        var multipart = [String: String]()
        multipart[ "modelId" ] = modelId ?? INTENT_MODEL_ID
        multipart[ "document" ] = text
        parameter[ "multipart" ] = multipart
        
        let httpPost = Command( commandCode: CommandCode.HTTP_POST, parameter: parameter as NSDictionary)
        httpPost.onResolve(fn: { (result) in
            guard let result = result as? NSDictionary else {
                onFail("No results returned")
                return
            }
            onSuccess( result )
        })
        httpPost.onReject(fn: onFail)
        CommandProcessor.queue(command: httpPost)
    }
}

class EinsteinVision {
    static let instance:EinsteinVision = EinsteinVision()
    
    let MAXSIZE:Double = 5000000
    let MODEL_ID   = "GeneralImageClassifier"
    
    func predict( token:String, modelId:String?=nil, base64:String, onSuccess:@escaping ((NSDictionary)->()), onFail:@escaping ((String)->())) {
        var parameter = [String: Any]()
        parameter[ "url" ] = "https://api.einstein.ai/v1/vision/predict"
        parameter[ "method" ] = "POST"
        
        var headers = [String: String]()
        headers[ "Authorization" ] = "Bearer " + token
        headers[ "Connection" ] = "keep-alive"
        headers[ "Cache-Control" ] = "no-cache"
        parameter[ "headers" ] = headers
        
        var multipart = [String: String]()
        multipart[ "modelId" ] = modelId ?? MODEL_ID
        multipart[ "sampleBase64Content" ] = base64
        parameter[ "multipart" ] = multipart
        
        let httpPost = Command( commandCode: CommandCode.HTTP_POST, parameter: parameter as NSDictionary)
        httpPost.onResolve(fn: { (result) in
            guard let result = result as? NSDictionary else {
                onFail("No results returned")
                return
            }
            onSuccess( result )
        })
        httpPost.onReject(fn: onFail)
        CommandProcessor.queue(command: httpPost)
    }
    
    func datasets( token:String, onSuccess:@escaping ((NSDictionary)->()), onFail:@escaping ((String)->()) ) {
        var parameter = [String: Any]()
        parameter[ "url" ] = "https://api.einstein.ai/v2/vision/datasets"
        parameter[ "method" ] = "GET"
        
        var headers = [String: String]()
        headers[ "Authorization" ] = "Bearer " + token
        headers[ "Cache-Control" ] = "no-cache"
        parameter[ "headers" ] = headers
        
        let httpGet = Command( commandCode: CommandCode.HTTP_POST, parameter: parameter as NSDictionary)
        httpGet.onResolve(fn: { (result) in
            guard let result = result as? NSDictionary else {
                onFail("No results returned")
                return
            }
            onSuccess( result )
        })
        httpGet.onReject(fn: onFail)
        CommandProcessor.queue(command: httpGet)
    }
    
    func models( token:String, datasetId:UInt64, onSuccess:@escaping ((NSDictionary)->()), onFail:@escaping ((String)->()) ) {
        var parameter = [String: Any]()
        parameter[ "url" ] = "https://api.einstein.ai/v2/vision/datasets/" + String(datasetId) + "/models"
        parameter[ "method" ] = "GET"
        
        var headers = [String: String]()
        headers[ "Authorization" ] = "Bearer " + token
        headers[ "Cache-Control" ] = "no-cache"
        parameter[ "headers" ] = headers
        
        let httpGet = Command( commandCode: CommandCode.HTTP_POST, parameter: parameter as NSDictionary)
        httpGet.onResolve(fn: { (result) in
            guard let result = result as? NSDictionary else {
                onFail("No results returned")
                return
            }
            onSuccess( result )
        })
        httpGet.onReject(fn: onFail)
        CommandProcessor.queue(command: httpGet)
    }
    
    func preprocessImage( imageFile: ImageFile, onSuccess:@escaping ((String)->()), onError:@escaping ((String)->()) ) {
        guard let data = imageFile.getFile() else {
            onError("no data")
            return
        }
        guard let uiimage = ImageFile.binaryToUIImage(binary: data) else {
            onError("no data")
            return
        }
        if let shouldResize = shouldResizeImage(ext:imageFile.getFileExtension(), imgSize: Double(data.count), imgWidth: Double(uiimage.size.width), imgHeight: Double(uiimage.size.height)) {
            let quality = NSMutableDictionary()
            quality.setValue(99, forKey: "quality")
            quality.setValue(shouldResize.value(forKey: "width"), forKey: "width")
            quality.setValue(shouldResize.value(forKey: "height"), forKey: "height")
            imageFile.getBase64Resized(option: quality, onSuccess: onSuccess, onFail: onError)
        } else {
            imageFile.getBase64Value(onSuccess: onSuccess, onFail: onError)
        }
    }
    
    func shouldResizeImage(ext:FileExtention, imgSize:Double, imgWidth:Double, imgHeight:Double) -> NSDictionary? {
        if( imgSize > MAXSIZE || ext != .JPEG || ext != .JPG || ext != .PNG) {
            let newArea = (imgHeight * imgWidth * MAXSIZE) / imgSize;
            let newWidth = floor(sqrt((imgWidth * newArea)/imgHeight));
            let newHeight = floor(newArea / newWidth);
            return ["width": newWidth, "height": newHeight]
        }
        return nil
    }
}
