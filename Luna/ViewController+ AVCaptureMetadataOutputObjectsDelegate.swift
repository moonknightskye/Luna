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
        if let avCaptureManager = AVCaptureManager.getActiveManager() {
            CommandProcessor.getCommand(commandCode: CommandCode.AV_CAPTURE_SCANCODE, ifFound: { (command) in
                if let avmgr = CommandProcessor.getAVCaptureManager(command: command) {
                    if avCaptureManager === avmgr {
                        var metadatas = [NSMutableDictionary]()
                        for metadataObject in metadataObjects {
                            if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                                let metadata = NSMutableDictionary()
                                metadata.setValue(readableObject.stringValue, forKey: "value")
                                metadata.setValue(readableObject.bounds.dictionaryRepresentation, forKey: "bounds")
                                metadata.setValue(avmgr.processPoints(points: readableObject.corners), forKey: "corners")
                                metadatas.append(metadata)
                            }
                        }
                        if !metadatas.isEmpty {
                            command.update(value: metadatas)
                        }
                    }
                }
            })
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
        
        if let avCaptureManager = AVCaptureManager.getActiveManager() {
            CommandProcessor.getCommand(commandCode: CommandCode.AV_CAPTURE_SHOOT_IMAGE, ifFound: { (command) in
                if let avmgr = CommandProcessor.getAVCaptureManager(command: command) {
                    if avCaptureManager === avmgr {
                        if !avCaptureManager.isLocked() {
                            avCaptureManager.lock()
                            DispatchQueue.global(qos: .userInteractive).async(execute: {
                                DispatchQueue.main.async {
                                    if let dataImage = UIImagePNGRepresentation(self.captureImage(sampleBuffer: sampleBuffer)) {
                                        do {
                                            let file = try File(fileId: File.generateID(), file: dataImage, document: "TEMP_IMAGE.PNG", path: SystemFilePath.CACHE.rawValue)
                                            command.resolve(value: file.toDictionary(), raw: file)
                                        } catch let error as NSError {
                                            command.reject(errorMessage: error.localizedDescription)
                                        }
                                        avCaptureManager.unlock()
                                    }
                                }
                            })
                        }
                    }
                } else {
                    command.reject(errorMessage: "AVManager is not active")
                }
            })
        }
    }
    
    private func captureImage( sampleBuffer:CMSampleBuffer ) -> UIImage{
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
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return resultImage
    }
    
}
