//
//  AVCapture.swift
//  Luna
//
//  Created by Mart Civil on 2017/05/09.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import WebKit

public enum AVCaptureError: Error {
    case UNKNOWN_ERROR
    case INVALID_MODE
}
extension AVCaptureError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .UNKNOWN_ERROR:
            return NSLocalizedString("Unknown Error occured", comment: "Error")
        case .INVALID_MODE:
            return NSLocalizedString("Invalid AVCapture Mode", comment: "Error")
        }
    }
}

public enum AVCaptureType:String {
    case CODEREADER             = "CODEREADER"
    case IMAGE                  = "IMAGE"
    case CAMERA                 = "CAMERA"
}

class AVCaptureManager {
    
    static var LIST:[AVCaptureManager] = [AVCaptureManager]();
    private var avcapture_id:Int!
    static var counter = 0;
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var captureMode:[AVCaptureType]!
    public var isActive:Bool = false
    private var hasDefaultFrameProperty:Bool = false
	private var avScaledDimention:CGRect!
    private var shootingPhoto:Bool = false
    
    public init( mode:[AVCaptureType] ) throws {
        captureMode = mode
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high //AVCaptureSessionPreset1920x1080
        
        let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
        } catch {
            throw AVCaptureError.UNKNOWN_ERROR
        }
        
        if (captureSession?.canAddInput(videoInput))! {
            captureSession?.addInput(videoInput)
        } else {
            throw FileError.UNKNOWN_ERROR
        }
        
        for cmode in captureMode {
            switch cmode {
            case .CODEREADER:
                let metadataOutput = AVCaptureMetadataOutput()
                if (captureSession.canAddOutput(metadataOutput)) {
                    captureSession.addOutput(metadataOutput)
                    metadataOutput.setMetadataObjectsDelegate( Shared.shared.ViewController, queue: DispatchQueue.main )
                    metadataOutput.metadataObjectTypes = [
                        AVMetadataObject.ObjectType.aztec,
                        AVMetadataObject.ObjectType.code128,
                        AVMetadataObject.ObjectType.code39,
                        AVMetadataObject.ObjectType.code39Mod43,
                        AVMetadataObject.ObjectType.code93,
                        AVMetadataObject.ObjectType.dataMatrix,
                        AVMetadataObject.ObjectType.ean13,
                        AVMetadataObject.ObjectType.ean8,
                        AVMetadataObject.ObjectType.face,
                        AVMetadataObject.ObjectType.interleaved2of5,
                        AVMetadataObject.ObjectType.itf14,
                        AVMetadataObject.ObjectType.pdf417,
                        AVMetadataObject.ObjectType.qr,
                        AVMetadataObject.ObjectType.upce
                    ]
                } else {
                    throw AVCaptureError.UNKNOWN_ERROR
                }
                break
            case .IMAGE:
                let photoOutput = AVCapturePhotoOutput()
                if( captureSession.canAddOutput( photoOutput ) ) {
                    captureSession.addOutput( photoOutput )
                } else {
                    throw FileError.UNKNOWN_ERROR
                }
                break
            case .CAMERA:
                let photoSilentOutput = AVCaptureVideoDataOutput()
                if( captureSession.canAddOutput( photoSilentOutput ) ) {
                    captureSession.addOutput( photoSilentOutput )
                    photoSilentOutput.alwaysDiscardsLateVideoFrames = true
                    photoSilentOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
                    photoSilentOutput.setSampleBufferDelegate( Shared.shared.ViewController, queue: DispatchQueue.main )
                } else {
                    throw FileError.UNKNOWN_ERROR
                }
                break
            //default:
            //    throw AVCaptureError.INVALID_MODE
            }
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        setToBack()
        
        AVCaptureManager.LIST.append( self )
    }
    
    public func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict.setValue(self.getID(), forKey: "avcapture_id")
        return dict
    }

	private func updateAVDimention() {
		let scaleValue = Utility.shared.getDimentionScaleValue(originalDimention: UIScreen.main.bounds, resizedDimention: self.previewLayer.bounds)
		self.avScaledDimention = Utility.shared.getScaledDimention(dimention: UIScreen.main.bounds, scale: scaleValue)
	}
    
    func setProperty( property: NSDictionary, animation: NSDictionary?=nil, onSuccess:((Bool)->())?=nil ) {
        if animation != nil {
            var duration = 0.0
            if let duration_val = animation!.value(forKey: "duration") as? Double {
                duration = duration_val
            }
            var delay = 0.0
            if let delay_val = animation!.value(forKey: "delay") as? Double {
                delay = delay_val
            }
            
            UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.setProperty(property: property)
            }, completion: { finished in
                if onSuccess != nil {
                    onSuccess!( finished )
                }
            })
        } else {
            self.setProperty(property: property)
            if onSuccess != nil {
                onSuccess!( true )
            }
        }
    }
    
    private func setProperty( property: NSDictionary ) {
        if let frame = property.value(forKeyPath: "frame") as? NSDictionary {
			var isDimentionChanged = false
            hasDefaultFrameProperty = true
            if let width = frame.value(forKeyPath: "width") as? CGFloat {
                self.previewLayer.frame.size.width = width
				isDimentionChanged = true
            }
            if let height = frame.value(forKeyPath: "height") as? CGFloat {
                self.previewLayer.frame.size.height = height
				isDimentionChanged = true
            }
			if isDimentionChanged {
				self.updateAVDimention()
			}

            if let x = frame.value(forKeyPath: "x") as? CGFloat {
                self.previewLayer.frame.origin.x = x
            }
            if let y = frame.value(forKeyPath: "y") as? CGFloat {
                self.previewLayer.frame.origin.y = y
            }
        }
        if let isOpaque = property.value(forKeyPath: "isOpaque") as? Bool {
            self.previewLayer.isOpaque = isOpaque;
        }
        if let alpha = property.value(forKeyPath: "opacity") as? Float {
            self.previewLayer.opacity = alpha
        }
    }
    
    func start( onSuccess:((Bool)->())?=nil, onFail:((String)->())?=nil ) {
        if previewLayer.superlayer != nil {
            if !captureSession.isRunning {
                for avCaptureManager in AVCaptureManager.LIST {
                    if avCaptureManager !== self {
                        avCaptureManager.stop()
                    }
                }
                isActive = true
                captureSession.startRunning()
                if onSuccess != nil {
                    onSuccess!(true)
                }
            } else {
                if onFail != nil {
                    onFail!( "CodeReader already running" )
                }
            }
        } else {
            if onFail != nil {
                onFail!( "CodeReader not embedded in a WKWebView" )
            }
        }
    }
    
    func stop( onSuccess:((Bool)->())?=nil, onFail:((String)->())?=nil ) {
        if previewLayer.superlayer != nil {
            if captureSession.isRunning {
                isActive = false
                captureSession.stopRunning()
                if onSuccess != nil {
                    onSuccess!(true)
                }
            } else {
                if onFail != nil {
                    onFail!( "CodeReader was already stopped" )
                }
            }
        } else {
            if onFail != nil {
                onFail!( "CodeReader not embedded in a WKWebView" )
            }
        }
    }
    
    func remove( withError:String ) {
        AVCaptureManager.remove(manager: self, withError:withError)
        print("AVCaptureManager \(self.getID()) removed from Queue")
    }
    public class func remove( manager:AVCaptureManager, withError:String ) {
        for ( index, avCapture) in AVCaptureManager.LIST.enumerated() {
            if manager === avCapture {
                manager.stop()
                manager.previewLayer.removeFromSuperlayer()
                AVCaptureManager.LIST.remove(at: index)
            }
        }
    }
    
    public class func getManager( avcapture_id:Int?=nil, avCapture:AVCaptureManager?=nil ) -> AVCaptureManager? {
        for (_, manager) in AVCaptureManager.LIST.enumerated() {
            if avcapture_id != nil && manager.getID() == avcapture_id {
                return manager
            } else if avCapture != nil && manager === avCapture {
                return manager
            }
        }
        return nil
    }
    
    public class func getActiveManager() -> AVCaptureManager? {
        for avCaptureManager in AVCaptureManager.LIST {
            if avCaptureManager.isActive {
                return avCaptureManager
            }
        }
        return nil
    }
    
    func setID(avcapture_id: Int) {
        if self.avcapture_id == nil {
            self.avcapture_id = avcapture_id
        } else {
            print("[ERROR] File ID already set")
        }
    }
    func getID() -> Int {
        if self.avcapture_id == nil {
            self.avcapture_id = AVCaptureManager.generateID()
        }
        return self.avcapture_id!
    }
    public class func generateID() -> Int {
        AVCaptureManager.counter += 1
        return AVCaptureManager.counter
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return self.previewLayer
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return self.captureSession
    }
    
    public func setToBack() {
        self.previewLayer.zPosition = -1
    }
    public func setToMiddle() {
        self.previewLayer.zPosition = 0
    }
    public func setToFront() {
        self.previewLayer.zPosition = 1
    }
    
    func inheritParentFrame(isFixed:Bool) {
        if !self.hasDefaultFrameProperty && self.previewLayer.superlayer != nil {
            self.previewLayer.frame.size.width = self.previewLayer.superlayer!.frame.size.width
            self.previewLayer.frame.size.height = self.previewLayer.superlayer!.frame.size.height
			updateAVDimention()
        }
    }

	func processPoints( points: [Any] ) -> [CFDictionary] {
		var pPoints = [CFDictionary]()
		for point in points {
			if let ppoint = point as? NSValue {
				if let cgpt = ppoint as? CGPoint {
					pPoints.append(Utility.shared.getAspectRatioCoordinates(origin: cgpt, originalDimention: self.avScaledDimention, resizedDimention: self.previewLayer.bounds).dictionaryRepresentation)
				}

			} 
		}
		return pPoints
	}
    
    func lock() {
        self.shootingPhoto = true
    }
    func unlock() {
        self.shootingPhoto = false
    }
    
    func isLocked() -> Bool {
        return self.shootingPhoto
    }
}
