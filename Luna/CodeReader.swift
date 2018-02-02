//
//  CoderReader.swift
//  Luna
//
//  Created by 志美瑠 真斗 on 2017/05/05.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import WebKit

class CodeReader {

	private static var SINGLETON:CodeReader?
	private var captureSession: AVCaptureSession!
	private var previewLayer: AVCaptureVideoPreviewLayer!
    private let stillImageOutput: AVCapturePhotoOutput!
    private let stillVideoOutput: AVCaptureVideoDataOutput!
    private var didTookPhoto = false
    private var didTakeSilentPhoto = false
    
	var onFound:((String)->Void)?

	let supportedCodeTypes = [
        AVMetadataObject.ObjectType.upce,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.qr]


	init() throws{
		captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
		let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
		let videoInput: AVCaptureDeviceInput
		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
		} catch {
			throw FileError.UNKNOWN_ERROR
		}

		if (captureSession?.canAddInput(videoInput))! {
			captureSession?.addInput(videoInput)
		} else {
			throw FileError.UNKNOWN_ERROR
		}

		let metadataOutput = AVCaptureMetadataOutput()
		if (captureSession.canAddOutput(metadataOutput)) {
			captureSession.addOutput(metadataOutput)

			metadataOutput.setMetadataObjectsDelegate(Shared.shared.ViewController, queue: DispatchQueue.main)
			metadataOutput.metadataObjectTypes = supportedCodeTypes
		} else {
			throw FileError.UNKNOWN_ERROR
		}
        
        stillImageOutput = AVCapturePhotoOutput()
        if( captureSession.canAddOutput(stillImageOutput) ) {
            captureSession.addOutput(stillImageOutput)
        } else {
            print("FAILED!!! stillImageOutput")
            throw FileError.UNKNOWN_ERROR
        }
        
        stillVideoOutput = AVCaptureVideoDataOutput()
        if( captureSession.canAddOutput(stillVideoOutput) ) {
            captureSession.addOutput(stillVideoOutput)
            
            stillVideoOutput.alwaysDiscardsLateVideoFrames = true
            stillVideoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
            stillVideoOutput.setSampleBufferDelegate(Shared.shared.ViewController, queue: DispatchQueue.main)
            
        } else {
            print("FAILED!!! stillVideoOutput")
            throw FileError.UNKNOWN_ERROR
        }
        

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
		previewLayer.frame = Shared.shared.ViewController.view.layer.bounds

		previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
		previewLayer.frame.size.width = 200
		previewLayer.frame.size.height = 200
		previewLayer.frame.origin.y = 200
		previewLayer.frame.origin.x = 100

		//previewLayer.transformedMetadataObject(for: <#AVMetadataObject!#>)
		//previewLayer.transformedMetadataObject()
	}

	class func getInstance() -> CodeReader? {
		if CodeReader.SINGLETON == nil {
			do {
				CodeReader.SINGLETON = try CodeReader()
			} catch _ as NSError {}
		}
		return CodeReader.SINGLETON
	}

	func embed( webview: WKWebView, isFixed:Bool?=true, onFound:((String)->())?=nil ) {
		if isFixed! {
			webview.layer.addSublayer( previewLayer )
		} else {
			webview.scrollView.layer.addSublayer( previewLayer )
		}
		if onFound != nil {
			self.onFound = { value in
				onFound!(value)
				//self.previewLayer?.removeFromSuperlayer()
			}
		}
	}

	func start(onSuccess:((Bool)->()), onFail:((String)->())) {
		if previewLayer.superlayer != nil {
			if !captureSession.isRunning {
				captureSession.startRunning()
				onSuccess(true)

			} else {
				onFail( "CodeReader already running" )
			}
		} else {
			onFail( "CodeReader not embedded in a WKWebView" )
		}
	}

	func stop(onSuccess:((Bool)->()), onFail:((String)->())) {
		if previewLayer.superlayer != nil {
			if captureSession.isRunning {
				captureSession.stopRunning()
				onSuccess(true)

			} else {
				onFail( "CodeReader was already stopped" )
			}
		} else {
			onFail( "CodeReader not embedded in a WKWebView" )
		}
	}

	func found( value: String ) {
		print( value )
		if onFound != nil {
			onFound!( value )
		}
	}
    
    func getResultThenTakePhoto( value: String ) {
        print( value )
        takePhoto()
    }
    
    func takePhoto() {
        if !didTookPhoto {
            didTookPhoto = true
            let settingsForMonitoring = AVCapturePhotoSettings()
            settingsForMonitoring.flashMode = .auto
            settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
            settingsForMonitoring.isHighResolutionPhotoEnabled = false
            stillImageOutput.capturePhoto(with: settingsForMonitoring, delegate: Shared.shared.ViewController)
        }

    }
    
    func takeSilentPhoto() {
        if var _:AVCaptureConnection = stillVideoOutput.connection( with: AVMediaType.video ) {
            didTakeSilentPhoto = true
        }
    }
    
    func isShutterPressed() -> Bool {
        return didTakeSilentPhoto
    }
    func imageTaken( image:UIImage ) {
        didTakeSilentPhoto = false
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return self.previewLayer
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return self.captureSession
    }
}
