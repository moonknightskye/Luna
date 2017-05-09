//
//  ViewController+ AVCaptureMetadataOutputObjectsDelegate.swift
//  Luna
//
//  Created by 志美瑠 真斗 on 2017/05/05.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

//http://qiita.com/inoue0426/items/4f31e61a494eeb507881
extension ViewController: AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

		if let instance = CodeReader.getInstance() {
            if let metadataObj = metadataObjects.first {
                if instance.supportedCodeTypes.contains((metadataObj as AnyObject).type) {
                    let readableObject = metadataObj as! AVMetadataMachineReadableCodeObject
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        instance.found(value: readableObject.stringValue)
                        instance.takeSilentPhoto()
                    }
            }
            
            
            
            
//            instance.takePhoto()
//			instance.stop(onSuccess: { (isStopped) in
//				if isStopped {
//					if let metadataObj = metadataObjects.first {
//						if instance.supportedCodeTypes.contains((metadataObj as AnyObject).type) {
//							let readableObject = metadataObj as! AVMetadataMachineReadableCodeObject
//							AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//							instance.found(value: readableObject.stringValue)
//						}
//					}
//				}
//				dismiss(animated: true)
//			}, onFail: { (errorMessage) in
//				print( errorMessage )
//			})
		}
	}
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)
            print("YAY")
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if let instance = CodeReader.getInstance() {
            if instance.isShutterPressed() {
                DispatchQueue.global(qos: .userInteractive).async(execute: {
                    DispatchQueue.main.async {
                        instance.imageTaken(image: self.captureImage(sampleBuffer: sampleBuffer))
                        instance.stop(onSuccess: { (isStopped) in }, onFail: {(message)in})
                    }
                })
            }
        }
        
        
    }
    
    func captureImage( sampleBuffer:CMSampleBuffer ) -> UIImage{
        let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress:UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext:CGContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue|CGBitmapInfo.byteOrder32Little.rawValue)!
        
        let imageRef:CGImage = newContext.makeImage()!
        let resultImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: .right)

        return resultImage
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
