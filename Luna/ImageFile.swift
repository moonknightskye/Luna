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

    private var localIdentifier:String?
    
	override init(){
		super.init()
	}

    public init( fileId:Int, uiimage:UIImage, exif:NSDictionary?=nil, savePath:String?=nil ) throws {
        super.init()
        self.setFileName(fileName: "TEMP_IMAGE.PNG")
        self.setFileExtension(fileext: .PNG)
        self.setPathType(pathType: .DOCUMENT_TYPE)
        self.setPath(path: savePath)
        self.setID(fileId: fileId)
        var didCreated = true
        
        if !self.isFolderExists() {
            FileManager.createDocumentFolder(relative: self.getPath(), onFail: { (error) in
                didCreated = false
            })
            if !didCreated {
                throw FileError.CANNOT_CREATE
            }
        }
        
        let file:Any = uiimage        
        
        FileManager.saveDocument(file: file, filename: self.getFileName()!, relative: self.getPath(), onSuccess: { (filePath) in
            self.setFilePath(filePath: filePath)
        }) { (error) in
            didCreated = false
        }
        if !didCreated {
            throw FileError.CANNOT_CREATE
        }
    }
    
    //( fileId:File.generateID(), phasset:phasset, assetURL: imageURL)
    public init( fileId:Int, localIdentifier:String, assetURL:URL ) throws {
        super.init()
        self.setID(fileId: fileId)
        
        self.setPathType(pathType: FilePathType.ASSET_TYPE)
        self.setFilePath(filePath: assetURL )
        self.setLocalIdentifier(localIdentifier: localIdentifier)
        
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        if results.count > 0 {
            self.setFileName(fileName: results.firstObject?.value(forKey: "filename") as! String)
        }
    }
    
    override init( fileId:Int, asset:String, filePath:URL ) {
        super.init( fileId:fileId, asset:asset, filePath:filePath)
//        if let asset = Photos.getAsset(fileURL: filePath) {
//            self.asset = asset
//        }
    }
    
    
    override init( fileId:Int, document:String, filePath: URL ) {
        super.init( fileId:fileId, document:document, filePath:filePath)
    }
    
    override init( fileId:Int, document:String, path:String?=nil, filePath:URL?=nil ) throws {
        try super.init( fileId:fileId, document: document, path: path, filePath: filePath)
    }
    
    
    override init( fileId:Int, bundle:String, filePath: URL ) {
        super.init( fileId:fileId, bundle: bundle, filePath: filePath)
    }
    override init( fileId:Int, bundle:String, path:String?=nil, filePath:URL?=nil ) throws {
        try super.init( fileId:fileId, bundle: bundle, path: path, filePath: filePath)
    }
    
	override init ( fileId:Int, path:String?=nil, filePath: URL ) {
		super.init( fileId:fileId, path: path, filePath: filePath)
	}

    override init( fileId:Int, url:String ) throws {
        try super.init( fileId:fileId, url:url )
    }
    
    init( imageFile: NSDictionary ) {
        let filePath:URL = URL( string: imageFile.value(forKeyPath: "file_path") as! String )!
        let pathType = FilePathType( rawValue: imageFile.value(forKeyPath: "path_type") as! String )!
        let fileId:Int! = imageFile.value(forKeyPath: "file_id") as? Int ?? File.generateID()
        
        switch pathType {
        case .BUNDLE_TYPE:
            let fileName:String = imageFile.value(forKeyPath: "filename") as! String
            super.init( fileId:fileId, bundle:fileName, filePath:filePath )
            return
        case .DOCUMENT_TYPE:
            let fileName:String = imageFile.value(forKeyPath: "filename") as! String
            super.init( fileId:fileId, document:fileName, filePath:filePath )
            return
        case .URL_TYPE:
            super.init()
            self.setFilePath(filePath: filePath)
            self.setPathType(pathType: FilePathType.URL_TYPE)
            return
        case .ASSET_TYPE:
            let fileName:String = imageFile.value(forKeyPath: "filename") as! String
            let localIdentifier:String = imageFile.value(forKeyPath: "localIdentifier") as! String
            super.init( fileId:fileId, asset:fileName, filePath:filePath )
            self.setLocalIdentifier(localIdentifier: localIdentifier)
            return
        }
        super.init()
    }

	convenience init( file:NSDictionary ) throws {
		var isValid = true

		let fileName:String? = file.value(forKeyPath: "filename") as? String
		let path:String? = file.value(forKeyPath: "path") as? String
        let fileId:Int! = file.value(forKeyPath: "file_id") as? Int ?? File.generateID()

		if let pathType = file.value(forKeyPath: "path_type") as? String {
			if let filePathType = FilePathType( rawValue: pathType ) {
				switch filePathType {
				case .BUNDLE_TYPE:
					if fileName != nil {
						try self.init( fileId:fileId, bundle: fileName!, path:path)
						return
					} else {
						isValid = false
					}
					break
				case .DOCUMENT_TYPE:
					if fileName != nil {
						try self.init( fileId:fileId, document: fileName!, path:path )
						return
					} else {
						isValid = false
					}
					break
				case .URL_TYPE:
					if path != nil {
						try self.init( fileId:fileId, url: path! )
						return
					}else {
						isValid = false
					}
					break
				case .ASSET_TYPE:
					if fileName != nil {
						let filePath:URL = URL( string: file.value(forKeyPath: "file_path") as! String )!
                        let localIdentifier:String = file.value(forKeyPath: "localIdentifier") as! String
						self.init( fileId:fileId, asset: fileName!, filePath:filePath)
                        self.setLocalIdentifier(localIdentifier: localIdentifier)
						return
					} else {
						isValid = false
					}
					break
				}

			} else {
				isValid = false
			}
		} else {
			isValid = false
		}

		if !isValid {
			throw FileError.INVALID_PARAMETERS
		}
		self.init()
	}

    public override func getBase64Value( onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ) {
        switch self.getPathType()! {
        case .ASSET_TYPE:
            let results = PHAsset.fetchAssets(withLocalIdentifiers: [self.getLocalIdentifier()!], options: nil)
            if results.count > 0 {
                Photos.getBinaryImage(asset: results.firstObject!, onSuccess: { (binaryData) in
                    onSuccess( Utility.shared.DataToBase64(data: binaryData) )
                }, onFail: { (error) in
                    onFail( error )
                })
            }
            break
        case .BUNDLE_TYPE, .DOCUMENT_TYPE:
            if let file = self.getFile() {
                onSuccess( Utility.shared.DataToBase64(data: file) )
            } else {
                onFail( FileError.INVALID_FORMAT.localizedDescription + ":  \(self.getFileExtension())" )
            }
            break
        default:
            onFail( FileError.UNKNOWN_ERROR.localizedDescription )
            break
        }
    }
    
    public func getBase64Resized( option:NSObject, onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ){
        let size = CGSize( width: option.value(forKeyPath: "width") as! CGFloat, height: option.value(forKeyPath: "height") as! CGFloat )
        let quality:Int = option.value(forKeyPath: "quality") as! Int
        let compression:CGFloat = CGFloat( quality/100 )
        switch self.getPathType()! {
        case .ASSET_TYPE:
            let results = PHAsset.fetchAssets(withLocalIdentifiers: [self.getLocalIdentifier()!], options: nil)
            if results.count > 0 {
                Photos.getBinaryImage(asset: results.firstObject!, onSuccess: { (binaryData) in
                    if let fullImage = ImageFile.binaryToUIImage(binary: binaryData) {
                        let resizedImage = ImageFile.resizeUIImage(image: fullImage, targetSize: size)
                        if quality >= 100 {
                            if let resizedBinary = ImageFile.pngToBase64(image: resizedImage) {
                                onSuccess( resizedBinary )
                            }
                        } else {
                            if let resizedBinary = ImageFile.jpgToBase64(image: resizedImage, compressionQuality: compression) {
                                onSuccess( resizedBinary )
                            }
                        }
                    } else {
                        onFail( FileError.UNKNOWN_ERROR.localizedDescription )
                    }
                }, onFail: { (error) in
                    onFail( error )
                })
            }
            break
        case .BUNDLE_TYPE, .DOCUMENT_TYPE:
            if let file = self.getFile() {
                if let fullImage = ImageFile.binaryToUIImage(binary: file) {
                    let resizedImage = ImageFile.resizeUIImage(image: fullImage, targetSize: size)
                    if quality >= 100 {
                        if let resizedBinary = ImageFile.pngToBase64(image: resizedImage) {
                            onSuccess( resizedBinary )
                        }
                    } else {
                        if let resizedBinary = ImageFile.jpgToBase64(image: resizedImage, compressionQuality: compression) {
                            onSuccess( resizedBinary )
                        }
                    }
				} else {
					onFail( FileError.UNKNOWN_ERROR.localizedDescription + " 1" )
				}
			} else {
				onFail( FileError.UNKNOWN_ERROR.localizedDescription + " 2")
			}
            break
        default:
            onFail( FileError.UNKNOWN_ERROR.localizedDescription )
            break
        }
    }
    
    public func setLocalIdentifier( localIdentifier: String ) {
        self.localIdentifier = localIdentifier
    }
    public func getLocalIdentifier() -> String? {
        return self.localIdentifier
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
		} else {
			return nil
		}
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
    
    public override func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        if let filename = self.getFileName() {
            dict.setValue(filename, forKey: "filename")
        }
        if let path = self.getPath() {
            dict.setValue(path, forKey: "path")
        }
        if let pathType = self.getPathType() {
            dict.setValue(pathType.rawValue, forKey: "path_type")
        }
        if let filePath = self.getFilePath() {
            dict.setValue(filePath.absoluteString, forKey: "file_path")
        }
        dict.setValue(self.getFileExtension().rawValue, forKey: "file_extension")
        dict.setValue(self.getID(), forKey: "file_id")
        dict.setValue(self.getFileType().rawValue, forKey: "object_type")
        dict.setValue(self.getLocalIdentifier(), forKey: "localIdentifier")
        return dict
    }
    
}
