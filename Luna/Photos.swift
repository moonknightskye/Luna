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
        } else {
            return false;
        }
        mediaPickerController.delegate = view as! (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
        view?.present( mediaPickerController, animated: true, completion: nil )
        return true;
    }
    
    public class func goToSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(url! as URL) { (result) in
            print( result )
        }
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
