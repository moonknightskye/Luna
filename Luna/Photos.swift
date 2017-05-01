//
//  Photos.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/14.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices

enum PHAssetMediaType : Int {
    case Unknown
    case Image
    case Video
    case Audio
}

enum PickerType: String {
    case PHOTO_LIBRARY      = "PHOTO_LIBRARY"
    case CAMERA             = "CAMERA"
    case VIDEO_LIBRARY      = "VIDEO_LIBRARY"
    case CAMCORDER          = "CAMCORDER"
}

class Photos {
    
    private static var photoAssets = [PHAsset]()
    
    public class func getMediaPickerController( view: UIViewController?, type:PickerType?=PickerType.PHOTO_LIBRARY ) -> Bool {
        let mediaPickerController = UIImagePickerController()
        mediaPickerController.allowsEditing = false
        
        if( type == PickerType.PHOTO_LIBRARY && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) ) {
            mediaPickerController.sourceType = .photoLibrary
            mediaPickerController.mediaTypes = [kUTTypeImage as String] //kUTTypeMovie kUTTypeImage
        } else if( type == PickerType.CAMERA && UIImagePickerController.isSourceTypeAvailable(.camera) ) {
            mediaPickerController.sourceType = .camera
            mediaPickerController.cameraCaptureMode = .photo
            mediaPickerController.modalPresentationStyle = .fullScreen
        } else if( type == PickerType.VIDEO_LIBRARY && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) ) {
            mediaPickerController.sourceType = .photoLibrary
            mediaPickerController.videoQuality = .typeHigh
            mediaPickerController.mediaTypes = [kUTTypeMovie as String] //kUTTypeMovie kUTTypeImage
        }  else if( type == PickerType.CAMCORDER && UIImagePickerController.isSourceTypeAvailable(.camera) ) {
            mediaPickerController.mediaTypes = [kUTTypeMovie as String]
            mediaPickerController.sourceType = .camera
            mediaPickerController.cameraCaptureMode = .video
            mediaPickerController.modalPresentationStyle = .fullScreen
            mediaPickerController.videoQuality = .typeHigh
            mediaPickerController.videoMaximumDuration = 10
        } else {
            return false;
        }
        mediaPickerController.delegate = view as! (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
        view?.present( mediaPickerController, animated: true, completion: nil )
        return true;
    }
    
    public class func appendEXIFtoImageBinary( uiimage:UIImage, exif:NSDictionary ) -> NSData {
        let imageData = UIImagePNGRepresentation(uiimage)
        
        let imageRef:CGImageSource = CGImageSourceCreateWithData((imageData! as CFData), nil)!
        let uti: CFString = CGImageSourceGetType(imageRef)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: imageData!)
        
        
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, imageRef, 0, (exif as CFDictionary))
        CGImageDestinationFinalize(destination)
        
        return dataWithEXIF
    }
    
    public class func getAsset( fileURL: URL ) -> PHAsset? {
        let result = PHAsset.fetchAssets(withALAssetURLs: [fileURL], options: nil)
        return result.firstObject
    }
    
    public class func getVideoAsset( fileURL: URL ) -> PHAsset? {
        let result = PHAsset.fetchAssets(with: .video, options: nil)
        return result.firstObject
    }
    
    public class func goToSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(url! as URL) { (result) in
            print( result )
        }
    }
    
    public class func getAllPhotosInfo() {
        photoAssets = []
        
        // 画像をすべて取得
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        assets.enumerateObjects({ (asset, index, stop) -> Void in
            self.photoAssets.append(asset as PHAsset)
        })
        print(photoAssets)
    }
    
    public class func getAllSortedPhotosInfo() {
        
        // ソート条件を指定
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        assets.enumerateObjects({ (asset, index, stop) -> Void in
            self.photoAssets.append(asset as PHAsset)
        })
        print(photoAssets)
    }
    
    public class func getPhotoAt( index:Int) -> PHAsset?{
        // ソート条件を指定
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        if( index < assets.count ) {
            return assets[ index ]
        }
        return nil
    }
    
    public class func getBinaryVideo( asset: PHAsset, onSuccess:@escaping ((Data)->()), onFail: @escaping((String)->())  ) {
        let manager: PHImageManager = PHImageManager()
        manager.requestAVAsset(forVideo: asset, options: nil) { (videoAsset, avaudio, _: [AnyHashable : Any]?) in
            
            if videoAsset != nil {
                if let vasset = videoAsset as? AVURLAsset {
                    if let binaryData = NSData(contentsOf: vasset.url) {
                        onSuccess( binaryData as Data )
                        return
                    }
                }
            }
            onFail( FileError.INEXISTENT.localizedDescription )
        }
    }
    
    public class func getBinaryImage( asset: PHAsset, onSuccess:@escaping ((Data)->()), onFail: @escaping((String)->())  ) {
        let manager: PHImageManager = PHImageManager()
        manager.requestImageData(for: asset, options: nil) { (binaryImage, info, orient, _: [AnyHashable : Any]?) in
            if binaryImage != nil {
                onSuccess( binaryImage! )
            } else {
                onFail( FileError.INEXISTENT.localizedDescription )
            }
        }
    }
    
    public class func getImage( asset: PHAsset, onSuccess:@escaping ((UIImage)->()), onFail: @escaping((String)->()) ) {
        Photos.getBinaryImage(asset: asset, onSuccess: { (binaryImage) in
            if let uiimage = ImageFile.binaryToUIImage(binary: binaryImage) {
                onSuccess( uiimage )
                return
            }
        }) { (error) in
            onFail( error )
        }
    }
    

    
}
