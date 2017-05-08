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
	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!
	var onFound:((String)->Void)?

	let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
	                          AVMetadataObjectTypeCode39Code,
	                          AVMetadataObjectTypeCode39Mod43Code,
	                          AVMetadataObjectTypeCode93Code,
	                          AVMetadataObjectTypeCode128Code,
	                          AVMetadataObjectTypeEAN8Code,
	                          AVMetadataObjectTypeEAN13Code,
	                          AVMetadataObjectTypeAztecCode,
	                          AVMetadataObjectTypePDF417Code,
	                          AVMetadataObjectTypeQRCode]


	init() throws{
		captureSession = AVCaptureSession()
		let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		let videoInput: AVCaptureDeviceInput
		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
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

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
		previewLayer.frame = Shared.shared.ViewController.view.layer.bounds

		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

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
				self.previewLayer?.removeFromSuperlayer()
			}
		}
		//previewLayer?.zPosition = -1


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
}
