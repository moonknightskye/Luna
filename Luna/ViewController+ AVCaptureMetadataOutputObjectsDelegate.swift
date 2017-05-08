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

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {

	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

		if let instance = CodeReader.getInstance() {
			instance.stop(onSuccess: { (isStopped) in
				if isStopped {
					if let metadataObj = metadataObjects.first {
						if instance.supportedCodeTypes.contains((metadataObj as AnyObject).type) {
							let readableObject = metadataObj as! AVMetadataMachineReadableCodeObject
							AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
							instance.found(value: readableObject.stringValue)
						}
					}
				}
				dismiss(animated: true)
			}, onFail: { (errorMessage) in
				print( errorMessage )
			})
		}
	}
}
