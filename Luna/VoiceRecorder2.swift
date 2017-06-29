//
//  RecordWav.swift
//  Luna
//
//  Created by 志美瑠 真斗 on 2017/06/21.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import AVFoundation


//https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
//https://stackoverflow.com/questions/42178958/write-array-of-floats-to-a-wav-audio-file-in-swift

class VoiceRecorder2 {

	static let instance:VoiceRecorder2 = VoiceRecorder2()
	var recordingSession: AVAudioSession!
	var audioRecorder: AVAudioRecorder!
	public var isPermitted = false
	var recorderAudioFile:File?

	init() {
		recordingSession = AVAudioSession.sharedInstance()
	}

	func checkPermission(onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->())) {
		do {
			try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
			try recordingSession.setActive(true)
			recordingSession.requestRecordPermission() { allowed in
				DispatchQueue.main.async {
					if allowed {
						VoiceRecorder2.instance.isPermitted = true
						//self.isPermitted = true
						onSuccess(true)
					} else {
						onFail("No Permission")
					}
				}
			}
		} catch {
			onFail("Failed to initialize")
			// failed to record!
		}
	}

	func startRecording( onSuccess:((Bool)->())?=nil, onFail:((String)->())?=nil ) {
		if !VoiceRecorder2.instance.isPermitted {
			if onFail != nil {
				onFail!( "No Permission to record" )
			}
			return
		}

		do {
			recorderAudioFile = try File(fileId: File.generateID(), file: Data(), document: "TEMP_RECORDING.m4a", path: SystemFilePath.CACHE.rawValue)
		} catch let e as NSError {
			if onFail != nil {
				onFail!( e.localizedDescription )
			}
			return
		}

//		let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC), //kAudioFormatLinearPCM
			AVSampleRateKey: Float64(16000.0),
			AVNumberOfChannelsKey: 1,
			AVLinearPCMBitDepthKey:32,
			AVLinearPCMIsFloatKey: true,
			AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
		] as [String : Any]

		do {
			audioRecorder = try AVAudioRecorder(url: recorderAudioFile!.getFilePath()!, settings: settings)
			audioRecorder.delegate = Shared.shared.ViewController
			audioRecorder.record()
			//recordButton.setTitle("Tap to Stop", for: .normal)

			print("recording.....")
//			let _ = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.finishRecording), userInfo: nil, repeats: false)

			if onSuccess != nil {
				onSuccess!(true)
			}
		} catch {
			finishRecording()
		}
	}

	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}

	func finishRecording( onSuccess:((File)->())?=nil, onFail:((String)->())?=nil ) {
		if audioRecorder.isRecording {
			audioRecorder.stop()
			audioRecorder = nil
			if onSuccess != nil {
				onSuccess!( recorderAudioFile! )
			}
		} else {
			if onFail != nil {
				onFail!("not recording")
			}
		}


		print( "stopped" );
		//let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
		//let wavFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
		//convertAudio(audioFilename, outputURL: wavFilename)
	}

}
