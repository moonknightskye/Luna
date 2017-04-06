//
//  ImageFile.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/16.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import Photos

class ImageFile: File {
    
    private var asset:PHAsset?
    
    public init( uiimage:UIImage, exif:NSDictionary?=nil, savePath:String?=nil ) throws {
        super.init()
        self.setFileName(fileName: "TEMP_IMAGE.PNG")
        self.setFileExtension(fileext: .PNG)
        self.setPathType(pathType: .DOCUMENT_TYPE)
        self.setPath(path: savePath)
        var didCreated = true
        
        if !self.isFolderExists() {
            FileManager.createDocumentFolder(relative: self.getPath(), onFail: { (error) in
                didCreated = false
            })
            if !didCreated {
                throw FileError.FAILED_TO_CREATE
            }
        }
        
        var file:Any = uiimage
        if exif != nil {
            file = Photos.appendEXIFtoImageBinary(uiimage: uiimage, exif: exif!)
        }
        
        
        FileManager.saveDocument(file: file, filename: self.getFileName()!, relative: self.getPath(), onSuccess: { (filePath) in
            self.setFilePath(filePath: filePath)
        }) { (error) in
            didCreated = false
        }
        if !didCreated {
            throw FileError.FAILED_TO_CREATE
        }
    }
    
    public init( assetURL:URL ) throws {
        super.init()
        if let asset = Photos.getAsset(fileURL: assetURL) {
            self.asset = asset
            
            self.setFileName(fileName: asset.value(forKey: "filename") as! String)
            self.setPathType(pathType: FilePathType.ASSET_TYPE)
            self.setFilePath(filePath: assetURL )
        } else {
            throw FileError.FILE_DOES_NOT_EXIST
        }
    }
    
    public override init( asset:String, filePath:URL ) {
        super.init( asset:asset, filePath:filePath)
        if let asset = Photos.getAsset(fileURL: filePath) {
            self.asset = asset
        }
    }
    
    
    public override init( document:String, filePath: URL ) {
        super.init( document:document, filePath:filePath)
    }
    
    public override init( document:String, path:String?=nil, filePath:URL?=nil ) throws {
        try super.init(document: document, path: path, filePath: filePath)
    }
    
    
    public override init( bundle:String, filePath: URL ) {
        super.init(bundle: bundle, filePath: filePath)
    }
    public override init( bundle:String, path:String?=nil, filePath:URL?=nil ) throws {
        try super.init(bundle: bundle, path: path, filePath: filePath)
    }
    
    public override init( filePath: URL ) {
        super.init( filePath:filePath )
    }
    
    public override init( url:String ) throws {
        try super.init( url:url )
    }
    
    public init( imageFile: NSDictionary ) {
        let filePath:URL = URL( string: imageFile.value(forKeyPath: "file_path") as! String )!
        let pathType = FilePathType( rawValue: imageFile.value(forKeyPath: "path_type") as! String )!
        
        switch pathType {
        case .BUNDLE_TYPE:
            let fileName:String = imageFile.value(forKeyPath: "filename") as! String
            super.init( bundle:fileName, filePath:filePath )
            return
        case .DOCUMENT_TYPE:
            let fileName:String = imageFile.value(forKeyPath: "filename") as! String
            super.init( document:fileName, filePath:filePath )
            return
        case .URL_TYPE:
            super.init( filePath:filePath )
            return
        case .ASSET_TYPE:
            let fileName:String = imageFile.value(forKeyPath: "filename") as! String
            super.init( asset:fileName, filePath:filePath )
            if let asset = Photos.getAsset(fileURL: filePath) {
                self.asset = asset
            }
            return
        }
        super.init()
    }
    
    public func getBase64Value( onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ) {
        switch self.getPathType()! {
        case .ASSET_TYPE:
            Photos.getBinaryImage(asset: self.asset!, onSuccess: { (binaryData) in
                onSuccess( Utility.shared.DataToBase64(data: binaryData) )
            }, onFail: { (error) in
                onFail( error )
            })
            break
        case .BUNDLE_TYPE, .DOCUMENT_TYPE:
            if let file = self.getFile() {
                onSuccess( Utility.shared.DataToBase64(data: file) )
            }
            onFail( "Invalid Image Format \(self.getFileExtension()) try converting to PNG" )
            break
        default:
            onFail( "Error happened" )
            break
        }
    }
    
    public func getBase64Resized( option:NSObject, onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ){
        let size = CGSize( width: option.value(forKeyPath: "width") as! CGFloat, height: option.value(forKeyPath: "height") as! CGFloat )
        let quality:Int = option.value(forKeyPath: "quality") as! Int
        let compression:CGFloat = CGFloat( quality/100 )
        switch self.getPathType()! {
        case .ASSET_TYPE:
            Photos.getBinaryImage(asset: self.asset!, onSuccess: { (binaryData) in
                if let fullImage = ImageFile.binaryToUIImage(binary: binaryData) {
                    let resizedImage = ImageFile.resizeUIImage(image: fullImage, targetSize: size)
                    if quality >= 100 {
                        if let resizedBinary = ImageFile.pngToBase64(image: resizedImage) {
                            onSuccess( resizedBinary )
                            return
                        }
                    } else {
                        if let resizedBinary = ImageFile.jpgToBase64(image: resizedImage, compressionQuality: compression) {
                            onSuccess( resizedBinary )
                            return
                        }
                    }
                }
                onFail( "Error in converting file" )
            }, onFail: { (error) in
                onFail( error )
            })
            break
        case .BUNDLE_TYPE, .DOCUMENT_TYPE:
            if let file = self.getFile() {
                if let fullImage = ImageFile.binaryToUIImage(binary: file) {
                    let resizedImage = ImageFile.resizeUIImage(image: fullImage, targetSize: size)
                    if quality >= 100 {
                        if let resizedBinary = ImageFile.pngToBase64(image: resizedImage) {
                            onSuccess( resizedBinary )
                            return
                        }
                    } else {
                        if let resizedBinary = ImageFile.jpgToBase64(image: resizedImage, compressionQuality: compression) {
                            onSuccess( resizedBinary )
                            return
                        }
                    }
                }
            }
            onFail( "Error in converting file" )
            break
        default:
            onFail( "Error happened" )
            break
        }
    }
    
    
    public class func resizeUIImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
//    public class func UIImageToBase64( uiimage:UIImage, fileExtention: FileExtention ) -> String? {
//        switch fileExtention {
//        case FileExtention.JPG, FileExtention.JPEG:
//            return ImageFile.jpgToBase64(image: uiimage)
//        case FileExtention.PNG, FileExtention.GIF:
//            return ImageFile.pngToBase64(image: uiimage)
//        default:
//            break
//        }
//        return nil
//    }
    
    public func getEXIFInfo(onSuccess:@escaping ((NSDictionary)->()), onFail:@escaping ((String)->())) {
        switch self.getPathType()! {
        case .ASSET_TYPE:
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.asset!.requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
                if let fullImage = CIImage(contentsOf: contentEditingInput!.fullSizeImageURL!) {
                    onSuccess( self.generateEXIFInfo( info: fullImage.properties as NSDictionary) )
                } else {
                    onFail( "No EXIF Data available" )
                }
            }
            break
        case .BUNDLE_TYPE, .DOCUMENT_TYPE:
            let fileURL = self.getFilePath()
            if let imageSource = CGImageSourceCreateWithURL(fileURL! as CFURL, nil) {
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
                if let dict = imageProperties as? [String: Any] {
                    onSuccess( self.generateEXIFInfo( info: dict as NSDictionary) )
                } else {
                    onFail( "No EXIF Data available" )
                }
            }
            break
        default:
            onFail( "No EXIF Data available" )
            break
        }
    }
    
    private func generateEXIFInfo( info: NSDictionary ) -> NSDictionary {
        let exif = extractTextFromDictionary( dictionary: info )
        print(info)
        print("==============")
        print(exif)
        return exif
    }
    
    private func extractTextFromDictionary( dictionary:NSDictionary ) -> NSDictionary {
        let dict = NSMutableDictionary()
        for (key, _) in dictionary {
            let data = dictionary[ key ]!
            switch( data ) {
            case is String, is Int, is Double, is Float, is NSArray:
                dict.setValue(data, forKey: key as! String)
                break
            case is NSDictionary:
                dict.setValue(extractTextFromDictionary(dictionary:data as! NSDictionary), forKey: key as! String)
                break
            default:
                break
            }
        }
        return dict
    }
    
//    public func base64ToUImage() -> UIImage? {
//        if let base64value = self.getBase64Value() {
//            return ImageFile.base64ToUImage(base64: base64value)
//        }
//        return nil
//    }
    public class func base64ToUImage( base64: String ) -> UIImage? {
        if let decodedData = NSData(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0) ) {
            if let uiimage = UIImage(data: decodedData as Data) {
                return uiimage
            }
        }
        return nil
    }
    
    public class func binaryToUIImage( binary: Data ) -> UIImage? {
        if let uiimage = UIImage( data: binary ) {
            return uiimage
        }
        return nil
    }
    
    public class func pngToBase64( image: UIImage ) -> String? {
        if let pngImage = UIImagePNGRepresentation(image) {
            return pngImage.base64EncodedString()
        }
        return nil
    }
    
    public class func jpgToBase64( image:UIImage, compressionQuality:CGFloat?=CGFloat(0) ) -> String? {
        if let jpgImage = UIImageJPEGRepresentation(image, compressionQuality!) {
            return jpgImage.base64EncodedString()
        }
        return nil
    }
    
}
